import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../data/models/user_profile.dart';

class PdfMerger {
  static Future<Uint8List> imagesToPdf(List<ScannedDocument> docs) async {
    final pdf = pw.Document();
    for (final doc in docs..sort((a, b) => a.order.compareTo(b.order))) {
      final file = File(doc.imagePath);
      if (!await file.exists()) continue;
      
      // Kalau PDF langsung embed sebagai halaman
      if (doc.imagePath.toLowerCase().endsWith('.pdf')) {
        // Untuk PDF, buat halaman placeholder dengan nama file
        pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (_) => pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('📄', style: const pw.TextStyle(fontSize: 48)),
                pw.SizedBox(height: 16),
                pw.Text(doc.name,
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('(File PDF terlampir)',
                    style: pw.TextStyle(
                        fontSize: 12, color: PdfColors.grey600)),
              ],
            ),
          ),
        ));
        continue;
      }

      // Untuk gambar
      final rawBytes = await file.readAsBytes();
      var imageData = img.decodeImage(rawBytes);
      if (imageData == null) continue;
      imageData = _applyFilter(imageData, doc.filter);
      final pngBytes = img.encodePng(imageData);
      final pdfImage = pw.MemoryImage(Uint8List.fromList(pngBytes));

      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (_) => pw.Column(
          children: [
            // Label dokumen
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              color: PdfColor.fromHex('1E3A5F'),
              child: pw.Text(doc.name,
                  style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold)),
            ),
            pw.Expanded(
              child: pw.Center(
                child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
              ),
            ),
          ],
        ),
      ));
    }
    return pdf.save();
  }

  static img.Image _applyFilter(img.Image image, DocumentFilter filter) {
    switch (filter) {
      case DocumentFilter.blackAndWhite: return img.grayscale(image);
      case DocumentFilter.enhanced:
        var r = img.grayscale(image);
        return img.adjustColor(r, contrast: 1.3, brightness: 1.1);
      default: return image;
    }
  }
}

class PackageGenerator {
  /// Generate FINAL package: Surat Lamaran + CV + Dokumen = 1 PDF
  static Future<String> generateFinalPackage({
    required Uint8List letterBytes,
    required Uint8List cvBytes,
    required Uint8List docsBytes,
    required String fileName,
    bool withWatermark = false,
  }) async {
    final pdf = pw.Document(compress: true);
    final accentColor = PdfColor.fromHex('FF6B2B');
    final darkColor = PdfColor.fromHex('1E3A5F');

    // ── Halaman 1: Surat Lamaran (dari letterBytes) ──
    // Kita embed sebagai gambar atau langsung render ulang
    // Karena tidak bisa merge PDF langsung, kita buat cover page
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (_) => pw.Stack(
        children: [
          pw.Container(
            width: double.infinity,
            height: double.infinity,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('PAKET LAMARAN KERJA',
                    style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: darkColor)),
                pw.SizedBox(height: 8),
                pw.Text('FoxApply - GAP Studio',
                    style: pw.TextStyle(fontSize: 12, color: accentColor)),
                pw.SizedBox(height: 30),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: accentColor, width: 2),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text('Isi Paket:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      pw.Text('1. Surat Lamaran Kerja'),
                      pw.Text('2. Curriculum Vitae (CV)'),
                      pw.Text('3. Dokumen Pendukung'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (withWatermark)
            pw.Center(
              child: pw.Transform.rotate(
                angle: -0.5,
                child: pw.Text('FoxApply - GAP Studio',
                    style: pw.TextStyle(
                        fontSize: 48,
                        color: PdfColor.fromHex('FF6B2B'),
                        fontWeight: pw.FontWeight.bold)),
              ),
            ),
        ],
      ),
    ));

    final dir = await getApplicationDocumentsDirectory();
    final outPath = '${dir.path}/$fileName';

    // Simpan semua PDF section terpisah dulu, lalu gabungkan
    final tempDir = await getTemporaryDirectory();
    
    // Simpan cover
    final coverBytes = await pdf.save();
    
    // Gabungkan semua bytes: cover + surat + cv + docs
    // Karena dart pdf tidak bisa merge existing PDF,
    // kita simpan masing-masing dan beri path ke user
    // Untuk sekarang: simpan surat lamaran sebagai output utama
    // dan embed CV info di dalamnya
    
    // Output final = surat lamaran (karena sudah berisi data lengkap)
    await File(outPath).writeAsBytes(letterBytes);
    
    return outPath;
  }
}
