package com.swifty.gallerycleaner

import io.flutter.embedding.android.FlutterActivity
import android.os.Build
import android.app.NotificationManager
import android.content.Context
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private lateinit var notificationManager: NotificationManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.swifty.gallerycleaner/device_info").setMethodCallHandler {
            call, result ->
            if (call.method == "getSdkInt") {
                result.success(Build.VERSION.SDK_INT)
            } else {
                result.notImplemented()
            }
        }
    }
}
