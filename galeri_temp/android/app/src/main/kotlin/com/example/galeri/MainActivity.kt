package com.example.galeri

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Notification
import android.content.Context
import android.os.Build
import android.os.Environment
import androidx.core.app.NotificationCompat
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "gallery_service"
    private val NOTIFICATION_ID = 1001
    private lateinit var notificationManager: NotificationManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "createNotificationChannel" -> {
                    createNotificationChannel(
                        call.argument<String>("channelId") ?: "gallery_analysis",
                        call.argument<String>("channelName") ?: "Galeri Analizi",
                        call.argument<String>("channelDescription") ?: "Galeri analiz durumu bildirimleri"
                    )
                    result.success(null)
                }
                "showProgressNotification" -> {
                    showProgressNotification(
                        call.argument<String>("title") ?: "Galeri Analizi",
                        call.argument<String>("content") ?: "Analiz başlatılıyor...",
                        call.argument<Int>("progress") ?: 0,
                        call.argument<Int>("maxProgress") ?: 100
                    )
                    result.success(null)
                }
                "updateProgressNotification" -> {
                    updateProgressNotification(
                        call.argument<String>("title") ?: "Galeri Analizi",
                        call.argument<String>("content") ?: "Analiz devam ediyor...",
                        call.argument<Int>("progress") ?: 0,
                        call.argument<Int>("maxProgress") ?: 100
                    )
                    result.success(null)
                }
                "cancelNotification" -> {
                    cancelNotification()
                    result.success(null)
                }
                "getFileSize" -> {
                    val filePath = call.argument<String>("filePath")
                    val fileSize = getFileSize(filePath)
                    result.success(fileSize)
                }
                "optimizePerformance" -> {
                    optimizePerformance()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun createNotificationChannel(channelId: String, channelName: String, channelDescription: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                channelName,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = channelDescription
                setShowBadge(false)
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun showProgressNotification(title: String, content: String, progress: Int, maxProgress: Int) {
        val notification = NotificationCompat.Builder(this, "gallery_analysis")
            .setContentTitle(title)
            .setContentText(content)
            .setSmallIcon(android.R.drawable.ic_menu_gallery)
            .setProgress(maxProgress, progress, false)
            .setOngoing(true)
            .setAutoCancel(false)
            .build()

        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    private fun updateProgressNotification(title: String, content: String, progress: Int, maxProgress: Int) {
        val notification = NotificationCompat.Builder(this, "gallery_analysis")
            .setContentTitle(title)
            .setContentText(content)
            .setSmallIcon(android.R.drawable.ic_menu_gallery)
            .setProgress(maxProgress, progress, false)
            .setOngoing(true)
            .setAutoCancel(false)
            .build()

        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    private fun cancelNotification() {
        notificationManager.cancel(NOTIFICATION_ID)
    }

    private fun getFileSize(filePath: String?): Long {
        return try {
            if (filePath != null) {
                val file = File(filePath)
                if (file.exists()) file.length() else 0L
            } else {
                0L
            }
        } catch (e: Exception) {
            0L
        }
    }

    private fun optimizePerformance() {
        // Android'e özgü performans optimizasyonları
        try {
            // Garbage collection'ı tetikle
            System.gc()
            
            // Runtime optimizasyonları
            val runtime = Runtime.getRuntime()
            val maxMemory = runtime.maxMemory()
            val usedMemory = runtime.totalMemory() - runtime.freeMemory()
            
            // Eğer bellek kullanımı %80'in üzerindeyse temizlik yap
            if (usedMemory > maxMemory * 0.8) {
                System.gc()
            }
        } catch (e: Exception) {
            // Hata durumunda sessizce devam et
        }
    }
}
