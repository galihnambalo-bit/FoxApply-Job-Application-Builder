import 'package:flutter/services.dart';

class NativePdfService {
  static const _channel = MethodChannel('com.foxapply.app/pdf');

  /// Merge beberapa PDF jadi 1 - menggunakan Android PdfRenderer native
  static Future<String> mergePdfs({
    required List<String> pdfPaths,
    required String outputPath,
  }) async {
    final result = await _channel.invokeMethod<String>('mergePdfs', {
      'pdfPaths': pdfPaths,
      'outputPath': outputPath,
    });
    return result ?? outputPath;
  }

  /// Render setiap halaman PDF jadi gambar JPG
  static Future<List<String>> renderPdfToImages({
    required String pdfPath,
    required String outputDir,
  }) async {
    final result = await _channel.invokeMethod<List>('renderPdfToImages', {
      'pdfPath': pdfPath,
      'outputDir': outputDir,
    });
    return result?.map((e) => e.toString()).toList() ?? [];
  }
}
