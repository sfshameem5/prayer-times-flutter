package com.example.prayer_times.qibla

import android.annotation.SuppressLint
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import android.view.Display
import android.view.Surface
import android.view.WindowManager
import kotlin.math.PI
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.tan

/**
 * Collects fused heading + location updates for Qibla with tilt compensation, low-pass filtering,
 * and multi-source location fallbacks.
 */
class QiblaProvider(
    private val context: Context,
    private val callback: (QiblaUpdate) -> Unit,
) : SensorEventListener, LocationListener {

    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager

    private var rotationSensor: Sensor? = null
    private var accelSensor: Sensor? = null
    private var magSensor: Sensor? = null

    private var accelValues = FloatArray(3)
    private var magValues = FloatArray(3)
    private var haveAccel = false
    private var haveMag = false
    private var rotationVectorValues = FloatArray(5)
    private var haveRotationVector = false

    // Tracks whether the device has all required sensors (rotation vector + accel + magnetometer).
    private var hasCriticalSensors = true
    // Tracks whether the magnetometer needs user calibration (figure-8).
    private var needsCalibration = false

    private var headingFiltered: Double? = null
    private var lastBearing: Double? = null
    private var lastLocation: Location? = null

    private var storedLat: Double = 0.0
    private var storedLng: Double = 0.0
    private var storedName: String = ""

    private var isListeningSensors = false
    private var isListeningLocation = false

    private val alpha = 0.12f // low-pass smoothing factor
    private val locationMinDistanceMeters = 10f

    fun start(storedLat: Double, storedLng: Double, storedName: String) {
        this.storedLat = storedLat
        this.storedLng = storedLng
        this.storedName = storedName

        startSensors()
        tryStartLocation()
    }

    fun stop() {
        stopSensors()
        stopLocation()
    }

    private fun startSensors() {
        if (isListeningSensors) return

        rotationSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        accelSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        magSensor = sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

        hasCriticalSensors = rotationSensor != null && accelSensor != null && magSensor != null

        if (!hasCriticalSensors) {
            // Device cannot provide compass heading; publish unsupported state so Flutter can disable the page.
            publishUpdate(
                fallbackMode = "unsupported",
                heading = null,
                bearing = computeQiblaBearing(lastLocation),
                location = lastLocation,
            )
            return
        }

        rotationSensor?.let { sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME) }
        accelSensor?.let { sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME) }
        magSensor?.let { sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME) }
        isListeningSensors = true
    }

    private fun stopSensors() {
        if (!isListeningSensors) return
        sensorManager.unregisterListener(this)
        isListeningSensors = false
    }

    @SuppressLint("MissingPermission")
    private fun tryStartLocation() {
        if (isListeningLocation) return
        val hasFine = PermissionUtils.hasFineLocation(context)
        val hasCoarse = PermissionUtils.hasCoarseLocation(context)
        if (!hasFine && !hasCoarse) {
            // Permission denied → rely on stored city
            publishUpdate(fallbackMode = "stored_city", location = null)
            return
        }

        val providers = listOf(LocationManager.GPS_PROVIDER, LocationManager.NETWORK_PROVIDER)
        for (provider in providers) {
            if (locationManager.isProviderEnabled(provider)) {
                try {
                    locationManager.requestLocationUpdates(provider, 2000L, locationMinDistanceMeters, this)
                    isListeningLocation = true
                } catch (_: SecurityException) {
                    // handled by fallback
                }
            }
        }

        // If neither provider is enabled, fall back immediately to stored city
        if (!isListeningLocation) {
            publishUpdate(fallbackMode = "stored_city", location = null)
            return
        }

        val lastKnown = providers.asSequence()
            .mapNotNull { provider ->
                try {
                    locationManager.getLastKnownLocation(provider)
                } catch (_: SecurityException) {
                    null
                }
            }
            .maxByOrNull { it.time }

        if (lastKnown != null) {
            onLocationChanged(lastKnown)
        } else {
            publishUpdate(fallbackMode = "gps_only", location = null)
        }
    }

    private fun stopLocation() {
        if (!isListeningLocation) return
        try {
            locationManager.removeUpdates(this)
        } catch (_: SecurityException) {
        }
        isListeningLocation = false
    }

    override fun onSensorChanged(event: SensorEvent) {
        when (event.sensor.type) {
            Sensor.TYPE_ROTATION_VECTOR -> {
                haveRotationVector = true
                if (event.values.size >= rotationVectorValues.size) {
                    rotationVectorValues = event.values.copyOf()
                } else {
                    System.arraycopy(event.values, 0, rotationVectorValues, 0, event.values.size)
                }
            }
            Sensor.TYPE_ACCELEROMETER -> {
                haveAccel = true
                accelValues = lowPass(event.values, accelValues)
            }
            Sensor.TYPE_MAGNETIC_FIELD -> {
                haveMag = true
                magValues = lowPass(event.values, magValues)
                updateCalibration(event.accuracy)
            }
        }

        // heading can be null on devices without compass; UI must fall back to bearing-only
        val heading = computeHeading()
        headingFiltered = heading?.let { lowPassAngle(headingFiltered, it, alpha.toDouble()) }
        val location = lastLocation
        val bearing = computeQiblaBearing(location)
        publishUpdate(
            fallbackMode = deriveFallbackMode(location),
            heading = headingFiltered,
            bearing = bearing,
            location = location,
        )
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        if (sensor?.type == Sensor.TYPE_MAGNETIC_FIELD) {
            updateCalibration(accuracy)
        }
    }

    override fun onLocationChanged(location: Location) {
        val previous = lastLocation
        if (previous != null) {
            val delta = location.distanceTo(previous)
            if (delta < locationMinDistanceMeters && location.accuracy >= previous.accuracy) {
                return
            }
        }
        lastLocation = location
        val bearing = computeQiblaBearing(location)
        publishUpdate(
            fallbackMode = deriveFallbackMode(location),
            heading = headingFiltered,
            bearing = bearing,
            location = location,
        )
    }

    override fun onProviderEnabled(provider: String) {}
    override fun onProviderDisabled(provider: String) {}
    override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}

    private fun computeHeading(): Double? {
        val rMatrix = FloatArray(9)
        val orientation = FloatArray(3)

        val rotationApplied = if (haveRotationVector) {
            SensorManager.getRotationMatrixFromVector(rMatrix, rotationVectorValues)
            true
        } else if (haveAccel && haveMag) {
            SensorManager.getRotationMatrix(rMatrix, null, accelValues, magValues)
        } else {
            false
        }

        if (!rotationApplied) return null

        val remappedMatrix = FloatArray(9)
        val rotation = getDeviceRotation()
        val xAxis = when (rotation) {
            Surface.ROTATION_90 -> SensorManager.AXIS_Y
            Surface.ROTATION_270 -> SensorManager.AXIS_MINUS_Y
            else -> SensorManager.AXIS_X
        }
        val yAxis = when (rotation) {
            Surface.ROTATION_180 -> SensorManager.AXIS_MINUS_Y
            Surface.ROTATION_270 -> SensorManager.AXIS_MINUS_X
            else -> SensorManager.AXIS_Y
        }
        SensorManager.remapCoordinateSystem(rMatrix, xAxis, yAxis, remappedMatrix)
        SensorManager.getOrientation(remappedMatrix, orientation)
        val azimuthRad = orientation[0].toDouble()
        var heading = Math.toDegrees(azimuthRad)
        if (heading < 0) heading += 360.0
        return heading
    }

    private fun computeQiblaBearing(location: Location?): Double {
        val lat1 = (location?.latitude ?: storedLat) * PI / 180
        val lon1 = (location?.longitude ?: storedLng) * PI / 180
        val lat2 = KAABA_LAT * PI / 180
        val lon2 = KAABA_LON * PI / 180

        val dLon = lon2 - lon1
        val y = sin(dLon)
        val x = cos(lat1) * tan(lat2) - sin(lat1) * cos(dLon)
        var bearing = Math.toDegrees(atan2(y, x))
        bearing = (bearing + 360) % 360
        lastBearing = bearing
        return bearing
    }

    private fun deriveFallbackMode(location: Location?): String {
        return when {
            !hasCriticalSensors -> "unsupported"
            haveRotationVector && haveAccel && haveMag -> "compass"
            haveRotationVector -> "rotation_vector_only"
            location != null -> "gps_only"
            else -> "stored_city"
        }
    }

    private fun publishUpdate(
        fallbackMode: String,
        heading: Double? = headingFiltered,
        bearing: Double? = lastBearing,
        location: Location? = lastLocation,
    ) {
        val update = QiblaUpdate(
            heading = heading,
            qiblaBearing = bearing,
            fallbackMode = fallbackMode,
            locationAccuracy = location?.accuracy,
            provider = location?.provider?.uppercase() ?: "STORED_CITY",
            needsCalibration = needsCalibration,
        )
        callback(update)
    }

    private fun updateCalibration(accuracy: Int) {
        val needsCal = accuracy == SensorManager.SENSOR_STATUS_UNRELIABLE ||
            accuracy == SensorManager.SENSOR_STATUS_ACCURACY_LOW
        if (needsCalibration != needsCal) {
            needsCalibration = needsCal
            publishUpdate(
                fallbackMode = deriveFallbackMode(lastLocation),
                heading = headingFiltered,
                bearing = lastBearing ?: computeQiblaBearing(lastLocation),
                location = lastLocation,
            )
        }
    }

    private fun lowPass(input: FloatArray, output: FloatArray): FloatArray {
        if (output.isEmpty()) return input
        for (i in input.indices) {
            output[i] = output[i] + alpha * (input[i] - output[i])
        }
        return output
    }

    private fun lowPassAngle(previous: Double?, current: Double, alpha: Double): Double {
        if (previous == null) return current
        var delta = current - previous
        while (delta > 180) delta -= 360
        while (delta < -180) delta += 360
        val filtered = previous + alpha * delta
        return (filtered + 360) % 360
    }

    private fun getDeviceRotation(): Int {
        val display: Display? = windowManager.defaultDisplay
        return display?.rotation ?: Surface.ROTATION_0
    }

    companion object {
        private const val KAABA_LAT = 21.4225
        private const val KAABA_LON = 39.8262
    }
}

data class QiblaUpdate(
    val heading: Double?,
    val qiblaBearing: Double?,
    val fallbackMode: String,
    val locationAccuracy: Float?,
    val provider: String?,
    val needsCalibration: Boolean,
)
