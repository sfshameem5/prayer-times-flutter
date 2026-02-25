package com.example.prayer_times.alarm

import android.content.Context
import android.util.Log
import java.util.Locale

object AlarmLocaleHelper {
    private const val TAG = "AlarmLocaleHelper"

    /**
     * Resolve the locale code for the alarm. Priority:
     * 1. Explicit [code] parameter (from AlarmData.localeCode, passed via intent extras)
     * 2. MMKV / FlutterSharedPreferences fallback
     * 3. System default
     */
    fun getLocaleCode(context: Context): String? {
        return try {
            val prefs = context.getSharedPreferences(
                "FlutterSharedPreferences",
                Context.MODE_PRIVATE
            )
            prefs.getString("flutter.languageCode", null)
        } catch (e: Exception) {
            Log.e(TAG, "Error reading locale from SharedPreferences: ${e.message}")
            null
        }
    }

    /**
     * Create a [Context] with the given locale [code] applied.
     * Returns the original context if [code] is null or empty.
     */
    fun applyLocale(context: Context, code: String?): Context {
        if (code.isNullOrEmpty()) return context
        return try {
            val locale = Locale(code)
            Locale.setDefault(locale)
            val config = context.resources.configuration
            config.setLocale(locale)
            config.setLayoutDirection(locale)
            context.createConfigurationContext(config)
        } catch (e: Exception) {
            Log.e(TAG, "applyLocale error: ${e.message}")
            context
        }
    }
}
