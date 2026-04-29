import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../data/models/user_profile.dart';
import '../../core/utils/cv_generator.dart';
import '../../core/utils/letter_generator.dart';

class PackageGenerator {
  /// Generate SEMUA jadi 1 PDF: Surat + CV + Dokumen
  static Future<String> generateAll({
    required UserProfile profile,
    required JobApplication job,
    required List<ScannedDocument> docs,
    required String locale,
    required int template,
    bool withWatermark = false,
    void Function(String)? onProgress,
  }) async {
    final isId = locale == 'id';
    final pdf = pw.Document(compress: true);
    final primaryColor = PdfColor.fromHex('1E3A5F');
    final accentColor = PdfColor.fromHex('FF6B2B');

    // ══════════════════════════════════════════════
    // HALAMAN 1: COVER / DAFTAR ISI
    // ══════════════════════════════════════════════
    onProgress?.call(isId ? 'Membuat halaman cover...' : 'Creating cover page...');
    
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(50),
      build: (_) => pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(children: [
              pw.Text(
                isId ? 'PAKET LAMARAN KERJA' : 'JOB APPLICATION PACKAGE',
                style: pw.TextStyle(
                  fontSize: 22, fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('FoxApply - GAP Studio',
                  style: pw.TextStyle(fontSize: 12, color: PdfColor.fromHex('FFB890'))),
            ]),
          ),
          pw.SizedBox(height: 30),
          pw.Text(profile.fullName,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          if (job.targetPosition.isNotEmpty)
            pw.Text(
              isId
                  ? 'Melamar posisi: ${job.targetPosition}'
                  : 'Applying for: ${job.targetPosition}',
              style: pw.TextStyle(fontSize: 13, color: accentColor),
            ),
          if (job.targetCompany.isNotEmpty)
            pw.Text(job.targetCompany,
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
          pw.SizedBox(height: 40),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: accentColor),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(isId ? 'Isi Paket:' : 'Package Contents:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.SizedBox(height: 8),
                pw.Text('1. ${isId ? "Surat Lamaran Kerja" : "Cover Letter"}'),
                pw.Text('2. Curriculum Vitae (CV)'),
                if (docs.isNotEmpty)
                  pw.Text('3. ${isId ? "Dokumen Pendukung (${docs.length} file)" : "Supporting Documents (${docs.length} files)"}'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            _formatDate(DateTime.now(), isId),
            style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
          ),
        ],
      ),
    ));

    // ══════════════════════════════════════════════
    // HALAMAN 2+: SURAT LAMARAN KERJA
    // ══════════════════════════════════════════════
    onProgress?.call(isId ? 'Membuat surat lamaran...' : 'Generating cover letter...');

    final dateStr = _formatDate(DateTime.now(), isId);
    
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(60, 50, 60, 50),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Judul halaman
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: accentColor, width: 2)),
            ),
            child: pw.Text(
              isId ? 'SURAT LAMARAN KERJA' : 'COVER LETTER',
              style: pw.TextStyle(
                fontSize: 14, fontWeight: pw.FontWeight.bold, color: primaryColor),
            ),
          ),
          pw.SizedBox(height: 20),

          // Kota & Tanggal
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              '${profile.city.isNotEmpty ? profile.city.toUpperCase() : "KOTA"}, $dateStr',
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
          pw.SizedBox(height: 16),

          // Kepada
          pw.Text(isId ? 'Kepada Yth.' : 'To,', style: const pw.TextStyle(fontSize: 11)),
          pw.Text(isId ? 'Bapak/Ibu HRD / Pimpinan' : 'The HR Manager / Director',
              style: const pw.TextStyle(fontSize: 11)),
          pw.Text(job.targetCompany,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.Text('Di', style: const pw.TextStyle(fontSize: 11)),
          pw.Text(isId ? 'Tempat' : 'Place', style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 16),

          pw.Text(isId ? 'Dengan hormat,' : 'Dear Sir/Madam,',
              style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 10),

          pw.Text(
            isId
                ? 'Bersama surat ini saya bermaksud untuk mengajukan surat lamaran pekerjaan di perusahaan yang Bapak/Ibu pimpin untuk posisi ${job.targetPosition}. Saya adalah kandidat yang berdedikasi, profesional, dan berkomitmen untuk memberikan kontribusi terbaik.'
                : 'I am writing to express my interest in the ${job.targetPosition} position at ${job.targetCompany}. I am a dedicated professional committed to delivering excellence.',
            style: const pw.TextStyle(fontSize: 11),
            textAlign: pw.TextAlign.justify,
          ),
          pw.SizedBox(height: 10),

          pw.Text(
            isId ? 'Maka untuk itu saya yang bertanda tangan di bawah ini:' : 'Allow me to introduce myself:',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 8),

          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('F8F9FC'),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(children: [
              _dataRow('Nama', profile.fullName, primaryColor),
              _dataRow(isId ? 'Pendidikan Terakhir' : 'Education',
                  profile.education.isNotEmpty
                      ? '${profile.education.first.degree} - ${profile.education.first.institution}'
                      : '-', primaryColor),
              _dataRow(isId ? 'No. Telepon' : 'Phone', profile.phone, primaryColor),
              _dataRow('Email', profile.email, primaryColor),
              _dataRow(isId ? 'Alamat' : 'Address',
                  '${profile.address}, ${profile.city}', primaryColor),
            ]),
          ),
          pw.SizedBox(height: 10),

          pw.Text(
            isId ? 'Sebagai bahan pertimbangan, saya lampirkan:' : 'I have enclosed the following:',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 6),
          pw.Text('1. ${isId ? "Daftar Riwayat Hidup (CV)" : "Curriculum Vitae (CV)"}',
              style: const pw.TextStyle(fontSize: 11)),
          if (docs.isNotEmpty) ...[
            ...docs.asMap().entries.map((e) =>
              pw.Text('${e.key + 2}. ${e.value.name}',
                  style: const pw.TextStyle(fontSize: 11))),
          ] else ...[
            pw.Text('2. ${isId ? "Foto Copy Ijazah" : "Copy of Diploma"}',
                style: const pw.TextStyle(fontSize: 11)),
            pw.Text('3. ${isId ? "Foto Copy KTP" : "Copy of ID Card"}',
                style: const pw.TextStyle(fontSize: 11)),
          ],
          pw.SizedBox(height: 10),

          pw.Text(
            isId
                ? 'Demikian surat lamaran ini saya buat. Besar harapan saya untuk dapat diberikan kesempatan mengikuti seleksi. Atas perhatian Bapak/Ibu, saya ucapkan terima kasih.'
                : 'I look forward to the opportunity to discuss my qualifications further. Thank you for your consideration.',
            style: const pw.TextStyle(fontSize: 11),
            textAlign: pw.TextAlign.justify,
          ),
          pw.SizedBox(height: 24),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(isId ? 'Hormat saya,' : 'Sincerely,',
                      style: const pw.TextStyle(fontSize: 11)),
                  pw.SizedBox(height: 50),
                  pw.Container(height: 1, width: 150, color: primaryColor),
                  pw.SizedBox(height: 4),
                  pw.Text(profile.fullName,
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold,
                          color: primaryColor)),
                ],
              ),
            ],
          ),
        ],
      ),
    ));

    // ══════════════════════════════════════════════
    // HALAMAN BERIKUTNYA: CV
    // ══════════════════════════════════════════════
    onProgress?.call(isId ? 'Membuat CV...' : 'Generating CV...');

    // Load foto
    pw.MemoryImage? photoImage;
    if (profile.photoPath != null) {
      final file = File(profile.photoPath!);
      if (await file.exists()) {
        photoImage = pw.MemoryImage(await file.readAsBytes());
      }
    }

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (_) => [
        // Header CV
        pw.Container(
          color: primaryColor,
          padding: const pw.EdgeInsets.all(24),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(profile.fullName,
                        style: pw.TextStyle(fontSize: 24,
                            fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    if (profile.experience.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(profile.experience.first.position,
                          style: pw.TextStyle(fontSize: 13,
                              color: PdfColor.fromHex('FFB890'))),
                    ],
                    pw.SizedBox(height: 14),
                    if (profile.email.isNotEmpty)
                      _iconText('✉', profile.email),
                    if (profile.phone.isNotEmpty)
                      _iconText('☎', profile.phone),
                    if (profile.address.isNotEmpty)
                      _iconText('⌂', '${profile.address}, ${profile.city}'),
                  ],
                ),
              ),
              if (photoImage != null)
                pw.Container(
                  width: 90, height: 120,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: accentColor, width: 3),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.ClipRRect(
                    horizontalRadius: 4, verticalRadius: 4,
                    child: pw.Image(photoImage, fit: pw.BoxFit.cover),
                  ),
                ),
            ],
          ),
        ),

        // Body CV
        pw.Container(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Kiri: Pengalaman + Pendidikan
              pw.Expanded(flex: 3, child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (profile.experience.isNotEmpty) ...[
                    _cvSection(isId ? 'PENGALAMAN KERJA' : 'WORK EXPERIENCE', accentColor),
                    pw.SizedBox(height: 8),
                    ...profile.experience.map((exp) => pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 12),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(exp.position, style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          pw.Text(exp.company, style: pw.TextStyle(
                              color: accentColor, fontSize: 11)),
                          pw.Text(
                            exp.currentlyWorking
                                ? '${exp.startDate} - ${isId ? "Sekarang" : "Present"}'
                                : '${exp.startDate} - ${exp.endDate}',
                            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                          ),
                          if (exp.description.isNotEmpty)
                            pw.Text(exp.description, style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    )),
                    pw.SizedBox(height: 16),
                  ],
                  if (profile.education.isNotEmpty) ...[
                    _cvSection(isId ? 'PENDIDIKAN' : 'EDUCATION', accentColor),
                    pw.SizedBox(height: 8),
                    ...profile.education.map((edu) => pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 10),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(edu.institution, style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          pw.Text('${edu.degree} - ${edu.major}',
                              style: const pw.TextStyle(fontSize: 11)),
                          pw.Text(
                            edu.gpa.isNotEmpty ? '${edu.graduationYear} | GPA: ${edu.gpa}' : edu.graduationYear,
                            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                          ),
                        ],
                      ),
                    )),
                  ],
                ],
              )),
              pw.SizedBox(width: 20),
              // Kanan: Skills
              pw.Expanded(flex: 2, child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (profile.skills.isNotEmpty) ...[
                    _cvSection(isId ? 'KEAHLIAN' : 'SKILLS', accentColor),
                    pw.SizedBox(height: 8),
                    ...profile.skills.map((skill) {
                      final pct = switch(skill.level) {
                        SkillLevel.beginner => 0.25,
                        SkillLevel.intermediate => 0.50,
                        SkillLevel.advanced => 0.75,
                        SkillLevel.expert => 1.0,
                      };
                      return pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(skill.name, style: const pw.TextStyle(fontSize: 10)),
                            pw.SizedBox(height: 3),
                            pw.Stack(children: [
                              pw.Container(height: 5, decoration: pw.BoxDecoration(
                                  color: PdfColors.grey200,
                                  borderRadius: pw.BorderRadius.circular(3))),
                              pw.Container(height: 5, width: 100 * pct,
                                  decoration: pw.BoxDecoration(
                                      color: accentColor,
                                      borderRadius: pw.BorderRadius.circular(3))),
                            ]),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              )),
            ],
          ),
        ),
      ],
    ));

    // ══════════════════════════════════════════════
    // HALAMAN TERAKHIR: DOKUMEN YANG DIUPLOAD/SCAN
    // ══════════════════════════════════════════════
    if (docs.isNotEmpty) {
      onProgress?.call(isId ? 'Menambahkan dokumen...' : 'Adding documents...');

      for (final doc in docs..sort((a, b) => a.order.compareTo(b.order))) {
        final file = File(doc.imagePath);
        if (!await file.exists()) continue;

        if (doc.imagePath.toLowerCase().endsWith('.pdf')) {
          // PDF: buat halaman keterangan
          pdf.addPage(pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            build: (_) => pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('FFF3E0'),
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: accentColor),
                  ),
                  child: pw.Column(children: [
                    pw.Text('📄', style: const pw.TextStyle(fontSize: 40)),
                    pw.SizedBox(height: 12),
                    pw.Text(doc.name,
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold,
                            color: primaryColor)),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      isId
                          ? 'File PDF ini dilampirkan dalam paket lamaran'
                          : 'This PDF file is attached in the application package',
                      style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                      textAlign: pw.TextAlign.center,
                    ),
                  ]),
                ),
              ],
            ),
          ));
        } else {
          // Gambar: tampilkan langsung
          final rawBytes = await file.readAsBytes();
          var imageData = img.decodeImage(rawBytes);
          if (imageData == null) continue;

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

          final pdfImage = pw.MemoryImage(
              Uint8List.fromList(img.encodePng(imageData)));

          pdf.addPage(pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(20),
            build: (_) => pw.Column(
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  color: primaryColor,
                  child: pw.Text(doc.name,
                      style: pw.TextStyle(
                          color: PdfColors.white, fontSize: 11,
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
      }
    }

    // ══════════════════════════════════════════════
    // SIMPAN FILE
    // ══════════════════════════════════════════════
    onProgress?.call(isId ? 'Menyimpan file...' : 'Saving file...');
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = profile.fullName.replaceAll(' ', '_');
    final outPath = '${dir.path}/FoxApply_${name}_$ts.pdf';
    await File(outPath).writeAsBytes(bytes);

    return outPath;
  }

  // Helper widgets
  static pw.Widget _iconText(String icon, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(children: [
        pw.Text(icon, style: pw.TextStyle(fontSize: 10, color: PdfColors.white)),
        pw.SizedBox(width: 6),
        pw.Flexible(child: pw.Text(text,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.white))),
      ]),
    );
  }

  static pw.Widget _cvSection(String title, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(
            fontSize: 11, fontWeight: pw.FontWeight.bold,
            color: color, letterSpacing: 1.2)),
        pw.SizedBox(height: 3),
        pw.Container(height: 2, width: 40, color: color),
        pw.SizedBox(height: 2),
      ],
    );
  }

  static pw.Widget _dataRow(String label, String value, PdfColor labelColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 130,
              child: pw.Text(label,
                  style: pw.TextStyle(fontSize: 10, color: labelColor))),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 10)),
          pw.Expanded(child: pw.Text(value.isNotEmpty ? value : '-',
              style: const pw.TextStyle(fontSize: 10))),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt, bool isId) {
    final monthsId = ['Januari','Februari','Maret','April','Mei','Juni',
        'Juli','Agustus','September','Oktober','November','Desember'];
    final monthsEn = ['January','February','March','April','May','June',
        'July','August','September','October','November','December'];
    final months = isId ? monthsId : monthsEn;
    return isId
        ? '${dt.day} ${months[dt.month - 1]} ${dt.year}'
        : '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

// Alias untuk backward compatibility
class PdfMerger {
  static Future<Uint8List> imagesToPdf(List<ScannedDocument> docs) async {
    return Uint8List(0); // tidak dipakai lagi
  }
}
