package com.foxapply.app

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.pdf.PdfDocument
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.foxapply.app/pdf"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "mergePdfs" -> {
                        val pdfPaths = call.argument<List<String>>("pdfPaths") ?: emptyList()
                        val outputPath = call.argument<String>("outputPath") ?: ""
                        try {
                            mergePdfs(pdfPaths, outputPath)
                            result.success(outputPath)
                        } catch (e: Exception) {
                            result.error("MERGE_ERROR", e.message, null)
                        }
                    }
                    "renderPdfToImages" -> {
                        val pdfPath = call.argument<String>("pdfPath") ?: ""
                        val outputDir = call.argument<String>("outputDir") ?: ""
                        try {
                            val imagePaths = renderPdfToImages(pdfPath, outputDir)
                            result.success(imagePaths)
                        } catch (e: Exception) {
                            result.error("RENDER_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun mergePdfs(pdfPaths: List<String>, outputPath: String) {
        val outputDoc = PdfDocument()
        var pageNumber = 1

        for (pdfPath in pdfPaths) {
            val file = File(pdfPath)
            if (!file.exists()) continue

            try {
                val fd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
                val renderer = PdfRenderer(fd)

                for (i in 0 until renderer.pageCount) {
                    val page = renderer.openPage(i)
                    
                    // Render ke bitmap A4 size (595x842 points = 72dpi)
                    val width = (page.width * 2f).toInt()
                    val height = (page.height * 2f).toInt()
                    
                    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                    bitmap.eraseColor(Color.WHITE)
                    page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                    page.close()

                    // Tambah ke output PDF
                    val pageInfo = PdfDocument.PageInfo.Builder(width, height, pageNumber++).create()
                    val outPage = outputDoc.startPage(pageInfo)
                    outPage.canvas.drawBitmap(bitmap, 0f, 0f, null)
                    outputDoc.finishPage(outPage)
                    bitmap.recycle()
                }

                renderer.close()
                fd.close()
            } catch (e: Exception) {
                // Skip file yang error
            }
        }

        val fos = FileOutputStream(outputPath)
        outputDoc.writeTo(fos)
        outputDoc.close()
        fos.close()
    }

    private fun renderPdfToImages(pdfPath: String, outputDir: String): List<String> {
        val imagePaths = mutableListOf<String>()
        val file = File(pdfPath)
        if (!file.exists()) return imagePaths

        val fd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
        val renderer = PdfRenderer(fd)

        for (i in 0 until renderer.pageCount) {
            val page = renderer.openPage(i)
            val width = (page.width * 2f).toInt()
            val height = (page.height * 2f).toInt()
            
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            bitmap.eraseColor(Color.WHITE)
            page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
            page.close()

            val outFile = File(outputDir, "page_${i+1}.jpg")
            val fos = FileOutputStream(outFile)
            bitmap.compress(Bitmap.CompressFormat.JPEG, 90, fos)
            fos.close()
            bitmap.recycle()

            imagePaths.add(outFile.absolutePath)
        }

        renderer.close()
        fd.close()
        return imagePaths
    }
}
