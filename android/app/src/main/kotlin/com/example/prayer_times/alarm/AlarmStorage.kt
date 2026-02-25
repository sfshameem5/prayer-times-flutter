package com.example.prayer_times.alarm

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject

data class AlarmData(
    val id: Int,
    val timestamp: Long,
    val title: String,
    val body: String,
    val audioPath: String,
    val isTest: Boolean = false
) {
    fun toJson(): JSONObject {
        return JSONObject().apply {
            put("id", id)
            put("timestamp", timestamp)
            put("title", title)
            put("body", body)
            put("audioPath", audioPath)
            put("isTest", isTest)
        }
    }

    companion object {
        fun fromJson(json: JSONObject): AlarmData {
            return AlarmData(
                id = json.getInt("id"),
                timestamp = json.getLong("timestamp"),
                title = json.getString("title"),
                body = json.getString("body"),
                audioPath = json.optString("audioPath", ""),
                isTest = json.optBoolean("isTest", false)
            )
        }
    }
}

class AlarmStorage(context: Context) {
    private val prefs: SharedPreferences =
        context.getSharedPreferences("prayer_alarms", Context.MODE_PRIVATE)

    companion object {
        private const val KEY_ALARMS = "scheduled_alarms"
    }

    fun saveAlarm(alarm: AlarmData) {
        val alarms = getAllAlarms().toMutableList()
        alarms.removeAll { it.id == alarm.id }
        alarms.add(alarm)
        saveAll(alarms)
    }

    fun removeAlarm(id: Int) {
        val alarms = getAllAlarms().toMutableList()
        alarms.removeAll { it.id == id }
        saveAll(alarms)
    }

    fun getAlarm(id: Int): AlarmData? {
        return getAllAlarms().find { it.id == id }
    }

    fun getAllAlarms(): List<AlarmData> {
        val json = prefs.getString(KEY_ALARMS, null) ?: return emptyList()
        return try {
            val array = JSONArray(json)
            (0 until array.length()).map { AlarmData.fromJson(array.getJSONObject(it)) }
        } catch (e: Exception) {
            emptyList()
        }
    }

    fun clearAll() {
        prefs.edit().remove(KEY_ALARMS).apply()
    }

    private fun saveAll(alarms: List<AlarmData>) {
        val array = JSONArray()
        alarms.forEach { array.put(it.toJson()) }
        prefs.edit().putString(KEY_ALARMS, array.toString()).apply()
    }
}
