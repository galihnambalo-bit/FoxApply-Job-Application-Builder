import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_profile.dart';
import '../../controllers/app_controller.dart';

class DocumentPickerScreen extends StatelessWidget {
  const DocumentPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    final isId = ctrl.locale.languageCode == 'id';

    return Scaffold(
      appBar: AppBar(
        title: Text(isId ? 'Tambah Dokumen' : 'Add Document'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isId ? 'Pilih cara menambahkan dokumen:' : 'Choose how to add document:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),

            // Upload PDF langsung
            _OptionCard(
              icon: Icons.picture_as_pdf,
              color: AppColors.error,
              title: isId ? 'Upload PDF' : 'Upload PDF',
              subtitle: isId
                  ? 'Ijazah, transkrip, sertifikat dalam format PDF'
                  : 'Diploma, transcript, certificate in PDF format',
              onTap: () => _pickPDF(context, ctrl, isId),
            ),
            const SizedBox(height: 12),

            // Upload gambar dari galeri
            _OptionCard(
              icon: Icons.photo_library,
              color: AppColors.accent,
              title: isId ? 'Upload dari Galeri' : 'Upload from Gallery',
              subtitle: isId
                  ? 'Foto dokumen dari galeri HP'
                  : 'Document photo from phone gallery',
              onTap: () => _pickImage(context, ctrl, isId, ImageSource.gallery),
            ),
            const SizedBox(height: 12),

            // Scan dengan kamera
            _OptionCard(
              icon: Icons.document_scanner,
              color: AppColors.primary,
              title: isId ? 'Scan dengan Kamera' : 'Scan with Camera',
              subtitle: isId
                  ? 'Foto langsung dokumen fisik dengan kamera'
                  : 'Directly photo physical document with camera',
              onTap: () => _pickImage(context, ctrl, isId, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  // Upload PDF
  Future<void> _pickPDF(BuildContext context, AppController ctrl, bool isId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return;

    for (final file in result.files) {
      if (file.path == null) continue;
      final doc = ScannedDocument(
        id: const Uuid().v4(),
        imagePath: file.path!,
        name: file.name.replaceAll('.pdf', ''),
        order: ctrl.scannedDocs.length,
      );
      ctrl.addScannedDoc(doc);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isId
            ? '${result.files.length} PDF berhasil ditambahkan!'
            : '${result.files.length} PDF added successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  // Upload/Scan gambar
  Future<void> _pickImage(BuildContext context, AppController ctrl, bool isId, ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (file == null) return;

    // Crop
    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: isId ? 'Sesuaikan Crop' : 'Adjust Crop',
          toolbarColor: AppColors.secondary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.primary,
        ),
      ],
    );

    final finalPath = cropped?.path ?? file.path;
    final doc = ScannedDocument(
      id: const Uuid().v4(),
      imagePath: finalPath,
      name: 'Dokumen ${ctrl.scannedDocs.length + 1}',
      order: ctrl.scannedDocs.length,
    );
    ctrl.addScannedDoc(doc);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isId ? 'Dokumen ditambahkan!' : 'Document added!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
