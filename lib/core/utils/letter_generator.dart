// lib/core/utils/letter_generator.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/user_profile.dart';

class LetterGenerator {
  static Future<Uint8List> generateCoverLetter({
    required UserProfile profile,
    required JobApplication job,
    required String locale,
  }) async {
    final isId = locale == 'id';
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('1E3A5F');
    final accentColor = PdfColor.fromHex('FF6B2B');

    final dateStr = _formatDate(job.applicationDate, isId);
    final bodyText = job.customLetterContent.isNotEmpty
        ? job.customLetterContent
        : _generateDefaultBody(profile, job, isId);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(60, 50, 60, 50),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      profile.fullName,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(profile.email,
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(profile.phone,
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(
                        '${profile.address}, ${profile.city}',
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Container(
                  width: 4,
                  height: 60,
                  color: accentColor,
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // Date
            pw.Text(dateStr, style: const pw.TextStyle(fontSize: 11)),
            pw.SizedBox(height: 16),

            // Recipient
            pw.Text(
              isId ? 'Yth. HRD/Manajer Rekrutmen' : 'Dear Hiring Manager,',
              style: pw.TextStyle(
                  fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(job.targetCompany,
                style: const pw.TextStyle(fontSize: 11)),
            pw.SizedBox(height: 16),

            // Subject
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              color: PdfColor.fromHex('F3F4F6'),
              child: pw.Text(
                isId
                    ? 'Perihal: Lamaran Kerja – ${job.targetPosition}'
                    : 'Re: Application for ${job.targetPosition} Position',
                style: pw.TextStyle(
                    fontSize: 11, fontWeight: pw.FontWeight.bold,
                    color: primaryColor),
              ),
            ),
            pw.SizedBox(height: 16),

            // Salutation
            pw.Text(
              isId ? 'Dengan hormat,' : 'Dear Sir/Madam,',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 10),

            // Body
            pw.Text(
              bodyText,
              style: const pw.TextStyle(fontSize: 11),
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 16),

            // Closing
            pw.Text(
              isId ? 'Hormat saya,' : 'Sincerely,',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: 40),
            pw.Text(
              profile.fullName,
              style: pw.TextStyle(
                  fontSize: 12, fontWeight: pw.FontWeight.bold,
                  color: primaryColor),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static String _generateDefaultBody(
      UserProfile profile, JobApplication job, bool isId) {
    final latestEdu = profile.education.isNotEmpty
        ? profile.education.first
        : null;
    final latestExp = profile.experience.isNotEmpty
        ? profile.experience.first
        : null;

    if (isId) {
      return '''Saya yang bertanda tangan di bawah ini, ${profile.fullName}, dengan ini mengajukan lamaran pekerjaan untuk posisi ${job.targetPosition} di ${job.targetCompany}.

${latestEdu != null ? 'Saya adalah lulusan ${latestEdu.degree} ${latestEdu.major} dari ${latestEdu.institution} tahun ${latestEdu.graduationYear}.' : ''}

${latestExp != null ? 'Saya memiliki pengalaman bekerja sebagai ${latestExp.position} di ${latestExp.company}, yang telah memberikan saya keterampilan dan pengetahuan yang relevan untuk posisi yang Anda tawarkan.' : ''}

Saya memiliki kemampuan ${profile.skills.take(3).map((s) => s.name).join(', ')} yang saya yakini dapat berkontribusi positif bagi ${job.targetCompany}.

Saya adalah individu yang berdedikasi, disiplin, dan mampu bekerja baik secara mandiri maupun dalam tim. Saya sangat antusias untuk bergabung dengan tim ${job.targetCompany} dan memberikan kontribusi terbaik saya.

Bersama surat lamaran ini, saya lampirkan CV dan dokumen pendukung untuk bahan pertimbangan Bapak/Ibu. Saya berharap dapat diberikan kesempatan untuk mengikuti seleksi lebih lanjut.

Atas perhatian dan kesempatan yang diberikan, saya ucapkan terima kasih.''';
    } else {
      return '''I am writing to express my strong interest in the ${job.targetPosition} position at ${job.targetCompany}.

${latestEdu != null ? 'I hold a ${latestEdu.degree} in ${latestEdu.major} from ${latestEdu.institution}, graduated in ${latestEdu.graduationYear}.' : ''}

${latestExp != null ? 'My experience as a ${latestExp.position} at ${latestExp.company} has equipped me with valuable skills and knowledge directly applicable to this role.' : ''}

I am proficient in ${profile.skills.take(3).map((s) => s.name).join(', ')}, which I believe will allow me to make meaningful contributions to ${job.targetCompany}.

I am a dedicated and results-oriented professional who works effectively both independently and as part of a team. I am excited about the opportunity to bring my expertise to ${job.targetCompany} and contribute to your continued success.

Enclosed please find my CV and supporting documents for your review. I welcome the opportunity to discuss how my background and skills align with your needs.

Thank you for your time and consideration.''';
    }
  }

  static String _formatDate(String dateStr, bool isId) {
    try {
      final dt = DateTime.parse(dateStr);
      final monthsEn = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final monthsId = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final months = isId ? monthsId : monthsEn;
      if (isId) {
        return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      } else {
        return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
      }
    } catch (_) {
      return dateStr;
    }
  }
}
