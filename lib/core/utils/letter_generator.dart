import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/user_profile.dart';

class LetterGenerator {
  static Future<Uint8List> generateCoverLetter({
    required UserProfile profile,
    required JobApplication job,
    required String locale,
    List<String>? attachments,
  }) async {
    final isId = locale == 'id';
    final pdf = pw.Document();
    final primaryColor = PdfColor.fromHex('1E3A5F');
    final accentColor = PdfColor.fromHex('FF6B2B');

    final dateStr = _formatDate(DateTime.now(), isId);
    
    // Default attachments
    final defaultAttachments = isId ? [
      'Daftar Riwayat Hidup (CV)',
      'Foto Copy Ijazah Terakhir',
      'Foto Copy KTP',
      'Foto Copy Transkrip Nilai',
      'Pas Foto 3x4',
      'Sertifikat Pendukung (jika ada)',
    ] : [
      'Curriculum Vitae (CV)',
      'Copy of Latest Diploma',
      'Copy of ID Card',
      'Academic Transcript',
      'Passport Photo 3x4',
      'Supporting Certificates (if any)',
    ];
    
    final finalAttachments = attachments ?? defaultAttachments;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(60, 50, 60, 50),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Kota & Tanggal
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                isId
                    ? '${profile.city.isNotEmpty ? profile.city.toUpperCase() : "KOTA"}, $dateStr'
                    : '$dateStr',
                style: const pw.TextStyle(fontSize: 11),
              ),
            ),
            pw.SizedBox(height: 16),

            // Kepada Yth
            pw.Text(isId ? 'Kepada Yth.' : 'To,',
                style: const pw.TextStyle(fontSize: 11)),
            pw.Text(
              isId
                  ? 'Bapak/Ibu HRD / Pimpinan'
                  : 'The HR Manager / Director',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.Text(job.targetCompany,
                style: pw.TextStyle(
                    fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.Text('Di', style: const pw.TextStyle(fontSize: 11)),
            pw.Text(isId ? 'Tempat' : 'Place',
                style: const pw.TextStyle(fontSize: 11)),
            pw.SizedBox(height: 16),

            // Salam
            pw.Text(isId ? 'Dengan hormat,' : 'Dear Sir/Madam,',
                style: const pw.TextStyle(fontSize: 11)),
            pw.SizedBox(height: 10),

            // Paragraf pembuka
            pw.Text(
              isId
                  ? 'Bersama surat ini saya bermaksud untuk mengajukan surat lamaran pekerjaan di perusahaan yang Bapak/Ibu pimpin. Berdasarkan informasi lowongan kerja yang saya terima, perusahaan Bapak/Ibu sedang membutuhkan tenaga kerja untuk posisi ${job.targetPosition}.'
                  : 'I am writing to express my strong interest in applying for the ${job.targetPosition} position at ${job.targetCompany}. I believe that my skills and experience make me a strong candidate for this role.',
              style: const pw.TextStyle(fontSize: 11),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 10),

            // Data diri
            pw.Text(
              isId
                  ? 'Maka untuk itu saya yang bertanda tangan di bawah ini:'
                  : 'Allow me to introduce myself:',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 8),

            // Tabel data diri
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('F8F9FC'),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                children: [
                  _dataRow(isId ? 'Nama' : 'Name', profile.fullName, primaryColor),
                  _dataRow(isId ? 'Pendidikan Terakhir' : 'Last Education',
                      profile.education.isNotEmpty
                          ? '${profile.education.first.degree} - ${profile.education.first.major}'
                          : '-',
                      primaryColor),
                  _dataRow(isId ? 'No. Telepon' : 'Phone', profile.phone, primaryColor),
                  _dataRow(isId ? 'Email' : 'Email', profile.email, primaryColor),
                  _dataRow(isId ? 'Alamat' : 'Address',
                      '${profile.address}, ${profile.city}', primaryColor),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Paragraf lampiran
            pw.Text(
              isId
                  ? 'Sebagai bahan pertimbangan bagi Bapak/Ibu, saya lampirkan:'
                  : 'As supporting documents, I have enclosed the following:',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 6),

            // Daftar lampiran
            ...finalAttachments.asMap().entries.map((e) =>
              pw.Text('${e.key + 1}. ${e.value}',
                  style: const pw.TextStyle(fontSize: 11))),

            pw.SizedBox(height: 10),

            // Penutup
            pw.Text(
              isId
                  ? 'Demikian surat lamaran ini saya buat dengan sebenar-benarnya. Besar harapan saya untuk dapat diberikan kesempatan mengikuti seleksi lebih lanjut. Atas perhatian dan kesempatan yang Bapak/Ibu berikan, saya ucapkan terima kasih.'
                  : 'I am confident that my qualifications and enthusiasm would be an asset to your organization. I look forward to the opportunity to discuss how my background aligns with your needs. Thank you for your time and consideration.',
              style: const pw.TextStyle(fontSize: 11),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 20),

            // TTD
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.SizedBox(width: 10),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      isId ? 'Hormat saya,' : 'Sincerely,',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                    pw.SizedBox(height: 40), // ruang TTD manual
                    pw.Container(
                      height: 1,
                      width: 150,
                      color: primaryColor,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      profile.fullName,
                      style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _dataRow(String label, String value, PdfColor labelColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(label,
                style: pw.TextStyle(fontSize: 10, color: labelColor)),
          ),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 10)),
          pw.Expanded(
            child: pw.Text(value.isNotEmpty ? value : '-',
                style: const pw.TextStyle(fontSize: 10)),
          ),
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
