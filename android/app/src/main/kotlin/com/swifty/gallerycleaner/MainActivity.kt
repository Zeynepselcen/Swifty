package com.swifty.gallerycleaner

import io.flutter.embedding.android.FlutterActivity
import android.os.Build
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.MediaStore
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import java.io.File

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

        // Gallery service method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "gallery_service").setMethodCallHandler { call, result ->
            when (call.method) {
                "refreshMediaStore" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath != null) {
                        refreshMediaStore(filePath)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "File path is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun refreshMediaStore(filePath: String) {
        try {
            val file = File(filePath)
            if (file.exists()) {
                // Android 10+ için ContentResolver kullan
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    try {
                        val contentValues = android.content.ContentValues().apply {
                            put(MediaStore.MediaColumns.DISPLAY_NAME, file.name)
                            put(MediaStore.MediaColumns.MIME_TYPE, getMimeType(file))
                            put(MediaStore.MediaColumns.RELATIVE_PATH, getRelativePath(file))
                        }
                        
                        val collection = if (isImageFile(file)) {
                            MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
                        } else {
                            MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
                        }
                        
                        contentResolver.insert(collection, contentValues)
                        println("ContentResolver ile MediaStore güncellendi: $filePath")
                    } catch (e: Exception) {
                        println("ContentResolver hatası: ${e.message}")
                    }
                }
                
                // Eski yöntem - broadcast ile MediaStore'u yenile
                val intent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
                intent.data = Uri.fromFile(file)
                sendBroadcast(intent)
                
                // Alternatif broadcast
                val mediaScanIntent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://$filePath"))
                sendBroadcast(mediaScanIntent)
                
                // Tüm galeriyi yenile
                val refreshIntent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
                sendBroadcast(refreshIntent)
                
                println("MediaStore yenilendi: $filePath")
            } else {
                println("Dosya bulunamadı: $filePath")
            }
        } catch (e: Exception) {
            println("MediaStore yenileme hatası: ${e.message}")
        }
    }
    
    private fun isImageFile(file: File): Boolean {
        val imageExtensions = arrayOf(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp")
        val extension = file.extension.lowercase()
        return imageExtensions.any { it == ".$extension" }
    }
    
    private fun getMimeType(file: File): String {
        return when (file.extension.lowercase()) {
            "jpg", "jpeg" -> "image/jpeg"
            "png" -> "image/png"
            "gif" -> "image/gif"
            "bmp" -> "image/bmp"
            "webp" -> "image/webp"
            "mp4" -> "video/mp4"
            "avi" -> "video/avi"
            "mov" -> "video/quicktime"
            "mkv" -> "video/x-matroska"
            else -> "application/octet-stream"
        }
    }
    
    private fun getRelativePath(file: File): String {
        val fullPath = file.absolutePath
        val dcimIndex = fullPath.indexOf("/DCIM/")
        if (dcimIndex != -1) {
            return fullPath.substring(dcimIndex + 1) // "/DCIM/" kısmını çıkar
        }
        return "DCIM/" + file.name
    }
}
