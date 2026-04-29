import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_profile.dart';
import '../../controllers/app_controller.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _ctrl = Get.find<AppController>();
  final _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isLoading = true);
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (file == null) { setState(() => _isLoading = false); return; }

      final cropped = await ImageCropper().cropImage(
        sourcePath: file.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Sesuaikan',
            toolbarColor: AppColors.secondary,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColors.primary,
            lockAspectRatio: false,
          ),
        ],
      );

      final finalPath = cropped?.path ?? file.path;
      _ctrl.addScannedDoc(ScannedDocument(
        id: const Uuid().v4(),
        imagePath: finalPath,
        name: 'Dokumen ${_ctrl.scannedDocs.length + 1}',
        order: _ctrl.scannedDocs.length,
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Dokumen berhasil ditambahkan!'),
              backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickPDF() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );
      if (result == null) { setState(() => _isLoading = false); return; }

      for (final f in result.files) {
        if (f.path == null) continue;
        _ctrl.addScannedDoc(ScannedDocument(
          id: const Uuid().v4(),
          imagePath: f.path!,
          name: f.name.replaceAll('.pdf', ''),
          order: _ctrl.scannedDocs.length,
        ));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${result.files.length} PDF ditambahkan!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _deleteDoc(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Dokumen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () { _ctrl.removeScannedDoc(id); Navigator.pop(context); },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dokumen')),
      body: Column(
        children: [
          // Tombol tambah dokumen
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Upload PDF
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Upload PDF (Ijazah, KTP, Sertifikat)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: const Text('Kamera'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: const Text('Galeri'),
                      ),
                    ),
                  ],
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(color: AppColors.primary),
                  ),
              ],
            ),
          ),

          // List dokumen
          Expanded(
            child: Obx(() {
              if (_ctrl.scannedDocs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_open, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      const Text('Belum ada dokumen',
                          style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      const Text('Upload PDF atau foto dokumen di atas',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          textAlign: TextAlign.center),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _ctrl.scannedDocs.length,
                itemBuilder: (_, i) {
                  final doc = _ctrl.scannedDocs[i];
                  final isPdf = doc.imagePath.toLowerCase().endsWith('.pdf');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: isPdf
                              ? AppColors.error.withValues(alpha: 0.1)
                              : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: isPdf
                            ? const Icon(Icons.picture_as_pdf, color: AppColors.error)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(doc.imagePath),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image, color: AppColors.primary)),
                              ),
                      ),
                      title: Text(doc.name,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(isPdf ? 'File PDF' : 'Foto Dokumen',
                          style: const TextStyle(fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => _deleteDoc(doc.id),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
