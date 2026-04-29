import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/user_profile.dart';

class CVGenerator {
  // Tema warna yang bisa dipilih
  static const Map<String, List<int>> themes = {
    'orange': [0xFF6B2B, 0x1E3A5F],
    'blue':   [0x1565C0, 0x0D3A6E],
    'green':  [0x2E7D32, 0x1B5E20],
    'purple': [0x6A1B9A, 0x4A148C],
    'red':    [0xC62828, 0x7F0000],
  };

  static Future<Uint8List> generateCV({
    required UserProfile profile,
    required int template,
    required String locale,
    String colorTheme = 'orange',
  }) async {
    final colors = themes[colorTheme] ?? themes['orange']!;
    final primaryColor = PdfColor.fromInt(colors[0] | 0xFF000000);
    final secondaryColor = PdfColor.fromInt(colors[1] | 0xFF000000);
    return _generateProfessional(profile, locale, primaryColor, secondaryColor);
  }

  static Future<Uint8List> _generateProfessional(
    UserProfile profile, String locale,
    PdfColor primaryColor, PdfColor secondaryColor,
  ) async {
    final pdf = pw.Document();
    final isId = locale == 'id';

    pw.MemoryImage? photoImage;
    if (profile.photoPath != null) {
      final file = File(profile.photoPath!);
      if (await file.exists()) {
        photoImage = pw.MemoryImage(await file.readAsBytes());
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => [
          // ── HEADER ─────────────────────────────────────
          pw.Container(
            color: secondaryColor,
            padding: const pw.EdgeInsets.all(24),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Kiri: nama + kontak
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        profile.fullName.isNotEmpty ? profile.fullName : 'Nama Lengkap',
                        style: pw.TextStyle(
                          fontSize: 26, fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      if (profile.experience.isNotEmpty) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          profile.experience.first.position,
                          style: pw.TextStyle(
                            fontSize: 13, color: PdfColor.fromHex('FFB890'),
                          ),
                        ),
                      ],
                      pw.SizedBox(height: 16),
                      if (profile.email.isNotEmpty)
                        _contactItem('✉', profile.email),
                      if (profile.phone.isNotEmpty)
                        _contactItem('☎', profile.phone),
                      if (profile.address.isNotEmpty)
                        _contactItem('⌂', '${profile.address}, ${profile.city}'),
                    ],
                  ),
                ),
                // Kanan: foto 3x4
                if (photoImage != null)
                  pw.Container(
                    width: 90, height: 120,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: primaryColor, width: 3),
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

          // ── BODY ──────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Kiri 60%: Pengalaman + Pendidikan
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Pengalaman Kerja
                      if (profile.experience.isNotEmpty) ...[
                        _sectionTitle(
                          isId ? 'PENGALAMAN KERJA' : 'WORK EXPERIENCE',
                          primaryColor,
                        ),
                        pw.SizedBox(height: 8),
                        ...profile.experience.map((exp) => pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 12),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(exp.position,
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold, fontSize: 12)),
                              pw.Text(exp.company,
                                  style: pw.TextStyle(
                                      color: primaryColor, fontSize: 11)),
                              pw.Text(
                                exp.currentlyWorking
                                    ? '${exp.startDate} - ${isId ? "Sekarang" : "Present"}'
                                    : '${exp.startDate} - ${exp.endDate}',
                                style: pw.TextStyle(
                                    fontSize: 10, color: PdfColors.grey600),
                              ),
                              if (exp.description.isNotEmpty)
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(top: 3),
                                  child: pw.Text(exp.description,
                                      style: const pw.TextStyle(fontSize: 10)),
                                ),
                            ],
                          ),
                        )),
                        pw.SizedBox(height: 16),
                      ],

                      // Pendidikan
                      if (profile.education.isNotEmpty) ...[
                        _sectionTitle(
                          isId ? 'PENDIDIKAN' : 'EDUCATION',
                          primaryColor,
                        ),
                        pw.SizedBox(height: 8),
                        ...profile.education.map((edu) => pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 10),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(edu.institution,
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold, fontSize: 12)),
                              pw.Text('${edu.degree} - ${edu.major}',
                                  style: const pw.TextStyle(fontSize: 11)),
                              pw.Text(
                                edu.gpa.isNotEmpty
                                    ? '${edu.graduationYear} | GPA: ${edu.gpa}'
                                    : edu.graduationYear,
                                style: pw.TextStyle(
                                    fontSize: 10, color: PdfColors.grey600),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ],
                  ),
                ),

                pw.SizedBox(width: 20),

                // Kanan 40%: Keahlian
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (profile.skills.isNotEmpty) ...[
                        _sectionTitle(
                          isId ? 'KEAHLIAN' : 'SKILLS',
                          primaryColor,
                        ),
                        pw.SizedBox(height: 8),
                        ...profile.skills.map((skill) {
                          final pct = switch(skill.level) {
                            SkillLevel.beginner     => 0.25,
                            SkillLevel.intermediate => 0.50,
                            SkillLevel.advanced     => 0.75,
                            SkillLevel.expert       => 1.0,
                          };
                          return pw.Container(
                            margin: const pw.EdgeInsets.only(bottom: 8),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(skill.name,
                                    style: const pw.TextStyle(fontSize: 10)),
                                pw.SizedBox(height: 3),
                                pw.Stack(children: [
                                  pw.Container(
                                    height: 5,
                                    decoration: pw.BoxDecoration(
                                      color: PdfColors.grey200,
                                      borderRadius: pw.BorderRadius.circular(3),
                                    ),
                                  ),
                                  pw.Container(
                                    height: 5,
                                    width: 100 * pct,
                                    decoration: pw.BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: pw.BorderRadius.circular(3),
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _contactItem(String icon, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(children: [
        pw.Text(icon, style: pw.TextStyle(fontSize: 10, color: PdfColors.white)),
        pw.SizedBox(width: 6),
        pw.Text(text, style: pw.TextStyle(fontSize: 10, color: PdfColors.white)),
      ]),
    );
  }

  static pw.Widget _sectionTitle(String title, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: pw.TextStyle(
                fontSize: 11, fontWeight: pw.FontWeight.bold,
                color: color, letterSpacing: 1.2)),
        pw.SizedBox(height: 3),
        pw.Container(height: 2, width: 40, color: color),
        pw.SizedBox(height: 2),
      ],
    );
  }
}
