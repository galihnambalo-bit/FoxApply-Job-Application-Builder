import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../data/models/user_profile.dart';
import 'letter_generator.dart';
import 'cv_generator.dart';
import 'native_pdf_service.dart';

class PackageGenerator {
  static Future<String> generateAll({
    required UserProfile profile,
    required JobApplication job,
    required List<ScannedDocument> docs,
    required String locale,
    required int template,
    void Function(String)? onProgress,
  }) async {
    final isId = locale == 'id';
    final dir = await getApplicationDocumentsDirectory();
    final tmpDir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = profile.fullName.replaceAll(' ', '_');

    // 1. Generate surat lamaran → simpan sebagai PDF
    onProgress?.call(isId ? 'Membuat surat lamaran...' : 'Generating cover letter...');
    final letterBytes = await LetterGenerator.generateCoverLetter(
      profile: profile, job: job, locale: locale,
    );
    final letterPath = '${tmpDir.path}/letter_$ts.pdf';
    await File(letterPath).writeAsBytes(letterBytes);

    // 2. Generate CV → simpan sebagai PDF
    onProgress?.call(isId ? 'Membuat CV...' : 'Generating CV...');
    final cvBytes = await CVGenerator.generateCV(
      profile: profile, template: template, locale: locale,
    );
    final cvPath = '${tmpDir.path}/cv_$ts.pdf';
    await File(cvPath).writeAsBytes(cvBytes);

    // 3. Kumpulkan semua PDF paths
    final allPdfPaths = <String>[letterPath, cvPath];

    // 4. Tambah dokumen yang diupload
    if (docs.isNotEmpty) {
      onProgress?.call(isId ? 'Memproses dokumen...' : 'Processing documents...');
      
      for (final doc in docs..sort((a, b) => a.order.compareTo(b.order))) {
        final file = File(doc.imagePath);
        if (!await file.exists()) continue;

        if (doc.imagePath.toLowerCase().endsWith('.pdf')) {
          // PDF langsung masuk list
          allPdfPaths.add(doc.imagePath);
        } else {
          // Gambar: konversi ke PDF dulu
          final imgBytes = await file.readAsBytes();
          var imageData = img.decodeImage(imgBytes);
          if (imageData == null) continue;

          // Rotate jika landscape
          if (imageData.width > imageData.height) {
            imageData = img.copyRotate(imageData, angle: 90);
          }

          // Apply filter
          switch (doc.filter) {
            case DocumentFilter.blackAndWhite:
              imageData = img.grayscale(imageData);
              break;
            case DocumentFilter.enhanced:
              imageData = img.grayscale(imageData);
              imageData = img.adjustColor(imageData, contrast: 1.3, brightness: 1.1);
              break;
            default: break;
          }

          // Buat PDF dari gambar
          final imgPdf = pw.Document();
          final pdfImg = pw.MemoryImage(
              Uint8List.fromList(img.encodeJpg(imageData, quality: 85)));
          
          imgPdf.addPage(pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(16),
            build: (_) => pw.Column(children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                color: PdfColor.fromHex('1E3A5F'),
                child: pw.Text(doc.name,
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 11,
                        fontWeight: pw.FontWeight.bold)),
              ),
              pw.Expanded(child: pw.Center(
                child: pw.Image(pdfImg, fit: pw.BoxFit.contain),
              )),
            ]),
          ));

          final imgPdfPath = '${tmpDir.path}/doc_${doc.id}_$ts.pdf';
          await File(imgPdfPath).writeAsBytes(await imgPdf.save());
          allPdfPaths.add(imgPdfPath);
        }
      }
    }

    // 5. MERGE SEMUA PDF PAKAI ANDROID NATIVE PdfRenderer!
    onProgress?.call(isId ? 'Menggabungkan semua PDF...' : 'Merging all PDFs...');
    final outputPath = '${dir.path}/FoxApply_${name}_$ts.pdf';

    try {
      // Pakai Android native PdfRenderer untuk merge
      await NativePdfService.mergePdfs(
        pdfPaths: allPdfPaths,
        outputPath: outputPath,
      );
      onProgress?.call(isId ? '✅ Selesai!' : '✅ Done!');
    } catch (e) {
      // Fallback: gabung manual dengan pdf package
      onProgress?.call(isId ? 'Menggunakan fallback...' : 'Using fallback...');
      await _fallbackMerge(allPdfPaths, outputPath);
    }

    // Cleanup temp files
    for (final path in allPdfPaths) {
      if (path.startsWith(tmpDir.path)) {
        try { await File(path).delete(); } catch (_) {}
      }
    }

    return outputPath;
  }

  /// Fallback: gabung semua jadi 1 PDF dengan render ulang
  static Future<void> _fallbackMerge(
      List<String> pdfPaths, String outputPath) async {
    final tmpDir = await getTemporaryDirectory();
    final mergedPdf = pw.Document(compress: true);

    for (final pdfPath in pdfPaths) {
      final file = File(pdfPath);
      if (!await file.exists()) continue;

      try {
        // Render PDF pages jadi gambar via native
        final imageDir = '${tmpDir.path}/render_${DateTime.now().millisecondsSinceEpoch}';
        await Directory(imageDir).create();
        
        final imagePaths = await NativePdfService.renderPdfToImages(
          pdfPath: pdfPath,
          outputDir: imageDir,
        );

        for (final imgPath in imagePaths) {
          final imgFile = File(imgPath);
          if (!await imgFile.exists()) continue;
          
          final pdfImg = pw.MemoryImage(await imgFile.readAsBytes());
          mergedPdf.addPage(pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (_) => pw.Image(pdfImg, fit: pw.BoxFit.cover),
          ));
        }

        // Cleanup render dir
        try { await Directory(imageDir).delete(recursive: true); } catch (_) {}
      } catch (e) {
        // skip
      }
    }

    await File(outputPath).writeAsBytes(await mergedPdf.save());
  }
}

class PdfMerger {
  static Future<Uint8List> imagesToPdf(List<ScannedDocument> docs) async => Uint8List(0);
}
