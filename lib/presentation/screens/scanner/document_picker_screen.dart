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
      appBar: AppBar(title: Text(isId ? 'Tambah Dokumen' : 'Add Document')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isId ? 'Pilih cara menambahkan:' : 'Choose how to add:',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.picture_as_pdf,
              color: AppColors.error,
              title: isId ? '📄 Upload PDF' : '📄 Upload PDF',
              subtitle: isId
                  ? 'Ijazah, transkrip, sertifikat (format PDF)'
                  : 'Diploma, transcript, certificate (PDF format)',
              onTap: () => _pickPDF(context, ctrl, isId),
            ),
            const SizedBox(height: 12),
            _OptionCard(
              icon: Icons.photo_library,
              color: AppColors.accent,
              title: isId ? '🖼️ Upload dari Galeri' : '🖼️ Upload from Gallery',
              subtitle: isId ? 'Foto dokumen dari galeri HP' : 'Document photo from gallery',
              onTap: () => _pickImage(context, ctrl, isId, ImageSource.gallery),
            ),
            const SizedBox(height: 12),
            _OptionCard(
              icon: Icons.document_scanner,
              color: AppColors.primary,
              title: isId ? '📷 Scan dengan Kamera' : '📷 Scan with Camera',
              subtitle: isId ? 'Foto langsung dokumen fisik' : 'Directly photo physical document',
              onTap: () => _pickImage(context, ctrl, isId, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPDF(BuildContext ctx, AppController ctrl, bool isId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (result == null) return;
    for (final f in result.files) {
      if (f.path == null) continue;
      ctrl.addScannedDoc(ScannedDocument(
        id: const Uuid().v4(),
        imagePath: f.path!,
        name: f.name.replaceAll('.pdf', ''),
        order: ctrl.scannedDocs.length,
      ));
    }
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(isId ? '${result.files.length} PDF ditambahkan!' : '${result.files.length} PDF added!'),
      backgroundColor: AppColors.success,
    ));
    Navigator.pop(ctx);
  }

  Future<void> _pickImage(BuildContext ctx, AppController ctrl, bool isId, ImageSource src) async {
    final file = await ImagePicker().pickImage(source: src, imageQuality: 90);
    if (file == null) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      uiSettings: [AndroidUiSettings(
        toolbarTitle: isId ? 'Sesuaikan' : 'Adjust',
        toolbarColor: AppColors.secondary,
        toolbarWidgetColor: Colors.white,
        activeControlsWidgetColor: AppColors.primary,
      )],
    );
    ctrl.addScannedDoc(ScannedDocument(
      id: const Uuid().v4(),
      imagePath: cropped?.path ?? file.path,
      name: 'Dokumen ${ctrl.scannedDocs.length + 1}',
      order: ctrl.scannedDocs.length,
    ));
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(isId ? 'Dokumen ditambahkan!' : 'Document added!'),
      backgroundColor: AppColors.success,
    ));
    Navigator.pop(ctx);
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _OptionCard({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

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
              width: 48, height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
