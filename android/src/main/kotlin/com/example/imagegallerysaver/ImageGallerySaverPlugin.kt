package com.example.imagegallerysaver

import android.content.Context
import android.graphics.BitmapFactory
import android.os.Environment
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.FileOutputStream

class ImageGallerySaverPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "image_gallery_saver")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "saveImageToGallery" -> {
                val imageBytes = call.argument<ByteArray>("imageBytes")
                val quality = call.argument<Int>("quality") ?: 80
                val name = call.argument<String>("name") ?: "IMG_${System.currentTimeMillis()}"

                if (imageBytes != null) {
                    val savedFile = saveImage(imageBytes, name, quality)
                    result.success(mapOf("isSuccess" to (savedFile != null), "filePath" to savedFile?.absolutePath))
                } else {
                    result.error("INVALID", "Image bytes are null", null)
                }
            }
            "saveFileToGallery" -> {
                val filePath = call.argument<String>("file")
                val name = call.argument<String>("name") ?: "FILE_${System.currentTimeMillis()}"
                if (filePath != null) {
                    val savedFile = saveFile(filePath, name)
                    result.success(mapOf("isSuccess" to (savedFile != null), "filePath" to savedFile?.absolutePath))
                } else {
                    result.error("INVALID", "File path is null", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun saveImage(imageBytes: ByteArray, name: String, quality: Int): File? {
        return try {
            val picturesDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
            val file = File(picturesDir, "$name.jpg")
            val fos = FileOutputStream(file)
            val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
            bitmap.compress(android.graphics.Bitmap.CompressFormat.JPEG, quality, fos)
            fos.flush()
            fos.close()
            file
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private fun saveFile(filePath: String, name: String): File? {
        return try {
            val srcFile = File(filePath)
            val picturesDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
            val destFile = File(picturesDir, "$name${srcFile.extension}")
            srcFile.copyTo(destFile, overwrite = true)
            destFile
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}
