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
      final rawBytes = await file.readAsBytes();
      var imageData = img.decodeImage(rawBytes);
      if (imageData == null) continue;
      imageData = _applyFilter(imageData, doc.filter);
      final pngBytes = img.encodePng(imageData);
      final pdfImage = pw.MemoryImage(Uint8List.fromList(pngBytes));
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (ctx) => pw.Center(
          child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
        ),
      ));
    }
    return pdf.save();
  }

  static img.Image _applyFilter(img.Image image, DocumentFilter filter) {
    switch (filter) {
      case DocumentFilter.blackAndWhite:
        return img.grayscale(image);
      case DocumentFilter.enhanced:
        var r = img.grayscale(image);
        r = img.adjustColor(r, contrast: 1.3, brightness: 1.1);
        return r;
      default:
        return image;
    }
  }
}

class PackageGenerator {
  static Future<String> generateFinalPackage({
    required List<Uint8List> pdfPages,
    required String fileName,
    bool withWatermark = false,
  }) async {
    final pdf = pw.Document(compress: true);
    for (final bytes in pdfPages) {
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => pw.Stack(children: [
          pw.Center(child: pw.Text('')),
          if (withWatermark) _buildWatermark(),
        ]),
      ));
    }
    final dir = await getApplicationDocumentsDirectory();
    final outPath = '${dir.path}/$fileName';
    final outBytes = pdfPages.isNotEmpty ? pdfPages[0] : Uint8List(0);
    await File(outPath).writeAsBytes(outBytes);
    return outPath;
  }

  static pw.Widget _buildWatermark() {
    return pw.Center(
      child: pw.Transform.rotate(
        angle: -0.5,
        child: pw.Text(
          'FoxApply - GAP Studio',
          style: pw.TextStyle(
            fontSize: 48,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('FF6B2B'),
          ),
        ),
      ),
    );
  }
}
