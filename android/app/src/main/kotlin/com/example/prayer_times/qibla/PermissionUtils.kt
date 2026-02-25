package com.example.prayer_times.qibla

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

object PermissionUtils {
    private const val REQUEST_CODE_LOCATION = 1011

    fun hasFineLocation(context: Context): Boolean =
        ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED

    fun hasCoarseLocation(context: Context): Boolean =
        ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED

    fun requestLocationIfNeeded(activity: Activity) {
        val needsFine = !hasFineLocation(activity)
        val needsCoarse = !hasCoarseLocation(activity)
        if (!needsFine && !needsCoarse) return

        val permissions = mutableListOf<String>()
        if (needsFine) permissions.add(Manifest.permission.ACCESS_FINE_LOCATION)
        if (needsCoarse) permissions.add(Manifest.permission.ACCESS_COARSE_LOCATION)

        if (permissions.isNotEmpty()) {
            ActivityCompat.requestPermissions(activity, permissions.toTypedArray(), REQUEST_CODE_LOCATION)
        }
    }
}
