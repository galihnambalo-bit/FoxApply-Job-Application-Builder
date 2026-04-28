// lib/core/utils/cv_generator.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/user_profile.dart';
import '../../core/constants/app_constants.dart';

class CVGenerator {
  static Future<Uint8List> generateCV({
    required UserProfile profile,
    required int template,
    required String locale,
  }) async {
    switch (template) {
      case AppConstants.templateProfessional:
        return _generateProfessional(profile, locale);
      case AppConstants.templateCreative:
        return _generateCreative(profile, locale);
      default:
        return _generateModern(profile, locale);
    }
  }

  static Future<Uint8List> _generateModern(
      UserProfile profile, String locale) async {
    final pdf = pw.Document();
    final isId = locale == 'id';

    pw.MemoryImage? photoImage;
    if (profile.photoPath != null) {
      final file = File(profile.photoPath!);
      if (await file.exists()) {
        photoImage = pw.MemoryImage(await file.readAsBytes());
      }
    }

    final primaryColor = PdfColor.fromHex('FF6B2B');
    final secondaryColor = PdfColor.fromHex('1E3A5F');
    final lightGray = PdfColor.fromHex('F3F4F6');
    final textGray = PdfColor.fromHex('6B7280');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (context) => [
          // Header
          pw.Container(
            color: secondaryColor,
            padding: const pw.EdgeInsets.all(30),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left: Name & Contact
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 8),
                      pw.Text(
                        profile.fullName.isNotEmpty
                            ? profile.fullName
                            : 'Your Name',
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      if (profile.experience.isNotEmpty)
                        pw.Text(
                          profile.experience.first.position,
                          style: pw.TextStyle(
                            fontSize: 13,
                            color: PdfColor.fromHex('FFB890'),
                          ),
                        ),
                      pw.SizedBox(height: 16),
                      _contactRow('✉', profile.email, PdfColors.white),
                      pw.SizedBox(height: 4),
                      _contactRow('☎', profile.phone, PdfColors.white),
                      pw.SizedBox(height: 4),
                      _contactRow('⌂',
                          '${profile.address}, ${profile.city}', PdfColors.white),
                    ],
                  ),
                ),
                // Right: Photo
                if (photoImage != null)
                  pw.Container(
                    width: 90,
                    height: 120,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                          color: primaryColor, width: 3),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.ClipRRect(
                      horizontalRadius: 6,
                      verticalRadius: 6,
                      child: pw.Image(photoImage, fit: pw.BoxFit.cover),
                    ),
                  ),
              ],
            ),
          ),

          // Body
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left column (60%)
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Experience
                      if (profile.experience.isNotEmpty) ...[
                        _sectionHeader(
                            isId ? 'PENGALAMAN KERJA' : 'WORK EXPERIENCE',
                            primaryColor),
                        pw.SizedBox(height: 8),
                        ...profile.experience.map((exp) => _experienceItem(
                            exp, textGray, primaryColor)),
                        pw.SizedBox(height: 16),
                      ],

                      // Education
                      if (profile.education.isNotEmpty) ...[
                        _sectionHeader(
                            isId ? 'PENDIDIKAN' : 'EDUCATION', primaryColor),
                        pw.SizedBox(height: 8),
                        ...profile.education
                            .map((edu) => _educationItem(edu, textGray)),
                        pw.SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(width: 20),
                // Right column (40%)
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Skills
                      if (profile.skills.isNotEmpty) ...[
                        _sectionHeader(
                            isId ? 'KEAHLIAN' : 'SKILLS', primaryColor),
                        pw.SizedBox(height: 8),
                        ...profile.skills.map((skill) =>
                            _skillItem(skill, primaryColor, lightGray)),
                        pw.SizedBox(height: 16),
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

  static Future<Uint8List> _generateProfessional(
      UserProfile profile, String locale) async {
    final pdf = pw.Document();
    final isId = locale == 'id';
    final primaryColor = PdfColor.fromHex('1E3A5F');
    final accentColor = PdfColor.fromHex('FF6B2B');

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
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(profile.fullName,
                      style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor)),
                  pw.SizedBox(height: 4),
                  if (profile.experience.isNotEmpty)
                    pw.Text(profile.experience.first.position,
                        style: pw.TextStyle(
                            fontSize: 14, color: accentColor)),
                  pw.SizedBox(height: 12),
                  pw.Text('${profile.email} | ${profile.phone}',
                      style: const pw.TextStyle(fontSize: 11)),
                  pw.Text(
                      '${profile.address}, ${profile.city} ${profile.postalCode}',
                      style: const pw.TextStyle(fontSize: 11)),
                ],
              ),
              if (photoImage != null)
                pw.Container(
                  width: 85,
                  height: 113,
                  child: pw.ClipRRect(
                    horizontalRadius: 4,
                    verticalRadius: 4,
                    child: pw.Image(photoImage, fit: pw.BoxFit.cover),
                  ),
                ),
            ],
          ),
          pw.Divider(color: accentColor, thickness: 2),
          pw.SizedBox(height: 12),

          if (profile.experience.isNotEmpty) ...[
            _sectionHeader(
                isId ? 'PENGALAMAN KERJA' : 'WORK EXPERIENCE', primaryColor),
            pw.SizedBox(height: 8),
            ...profile.experience
                .map((e) => _experienceItem(e, PdfColors.grey, accentColor)),
            pw.SizedBox(height: 12),
          ],

          if (profile.education.isNotEmpty) ...[
            _sectionHeader(isId ? 'PENDIDIKAN' : 'EDUCATION', primaryColor),
            pw.SizedBox(height: 8),
            ...profile.education
                .map((e) => _educationItem(e, PdfColors.grey)),
            pw.SizedBox(height: 12),
          ],

          if (profile.skills.isNotEmpty) ...[
            _sectionHeader(isId ? 'KEAHLIAN' : 'SKILLS', primaryColor),
            pw.SizedBox(height: 8),
            pw.Wrap(
              spacing: 8,
              runSpacing: 6,
              children: profile.skills
                  .map((s) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: primaryColor),
                          borderRadius: pw.BorderRadius.circular(20),
                        ),
                        child: pw.Text(s.name,
                            style: pw.TextStyle(
                                fontSize: 10, color: primaryColor)),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
    return pdf.save();
  }

  static Future<Uint8List> _generateCreative(
      UserProfile profile, String locale) async {
    // Similar structure but with creative layout
    return _generateModern(profile, locale); // Fallback for now
  }

  // Helper Widgets
  static pw.Widget _contactRow(
      String icon, String text, PdfColor color) {
    return pw.Row(
      children: [
        pw.Text(icon,
            style: pw.TextStyle(fontSize: 10, color: color)),
        pw.SizedBox(width: 6),
        pw.Text(text,
            style: pw.TextStyle(fontSize: 10, color: color)),
      ],
    );
  }

  static pw.Widget _sectionHeader(String title, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: color,
                letterSpacing: 1.2)),
        pw.SizedBox(height: 4),
        pw.Container(height: 2, width: 40, color: color),
      ],
    );
  }

  static pw.Widget _experienceItem(
      Experience exp, PdfColor dateColor, PdfColor accentColor) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(exp.position,
              style: pw.TextStyle(
                  fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.Text(exp.company,
              style: pw.TextStyle(fontSize: 11, color: accentColor)),
          pw.Text(
            exp.currentlyWorking
                ? '${exp.startDate} - Present'
                : '${exp.startDate} - ${exp.endDate}',
            style: pw.TextStyle(fontSize: 10, color: dateColor),
          ),
          if (exp.description.isNotEmpty)
            pw.Text(exp.description,
                style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _educationItem(Education edu, PdfColor dateColor) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(edu.institution,
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.Text('${edu.degree} - ${edu.major}',
              style: const pw.TextStyle(fontSize: 11)),
          pw.Text(
            edu.gpa.isNotEmpty
                ? '${edu.graduationYear} | GPA: ${edu.gpa}'
                : edu.graduationYear,
            style: pw.TextStyle(fontSize: 10, color: dateColor),
          ),
        ],
      ),
    );
  }

  static pw.Widget _skillItem(
      Skill skill, PdfColor primaryColor, PdfColor bgColor) {
    final levelWidth = switch (skill.level) {
      SkillLevel.beginner => 0.25,
      SkillLevel.intermediate => 0.5,
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
          pw.Stack(
            children: [
              pw.Container(
                height: 5,
                decoration: pw.BoxDecoration(
                  color: bgColor,
                  borderRadius: pw.BorderRadius.circular(3),
                ),
              ),
              pw.Container(width: 100 * levelWidth,
                widthFactor: levelWidth,
                child: pw.Container(
                  height: 5,
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
