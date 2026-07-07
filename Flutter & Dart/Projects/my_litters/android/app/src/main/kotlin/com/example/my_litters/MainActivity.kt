package com.example.my_litters

import android.content.Context
import android.content.pm.PackageManager
import android.nfc.NfcAdapter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "my_litters/hce"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                val prefs =
                    getSharedPreferences(CardEmulationService.PREFS, Context.MODE_PRIVATE)
                when (call.method) {
                    "isSupported" -> result.success(isHceSupported())

                    "enable" -> {
                        val uid = call.argument<String>("uid")
                        if (uid.isNullOrEmpty()) {
                            result.error("INVALID_UID", "uid is required", null)
                        } else {
                            prefs.edit()
                                .putString(CardEmulationService.KEY_UID, uid)
                                .putBoolean(CardEmulationService.KEY_ENABLED, true)
                                .apply()
                            result.success(true)
                        }
                    }

                    "disable" -> {
                        prefs.edit()
                            .putBoolean(CardEmulationService.KEY_ENABLED, false)
                            .apply()
                        result.success(true)
                    }

                    "status" -> {
                        result.success(
                            hashMapOf(
                                "supported" to isHceSupported(),
                                "enabled" to prefs.getBoolean(
                                    CardEmulationService.KEY_ENABLED, false
                                ),
                                "uid" to prefs.getString(CardEmulationService.KEY_UID, null),
                            )
                        )
                    }

                    else -> result.notImplemented()
                }
            }
    }

    /** True only if the device has HCE hardware and NFC is currently on. */
    private fun isHceSupported(): Boolean {
        if (!packageManager.hasSystemFeature(PackageManager.FEATURE_NFC_HOST_CARD_EMULATION)) {
            return false
        }
        val adapter = NfcAdapter.getDefaultAdapter(this) ?: return false
        return adapter.isEnabled
    }
}
