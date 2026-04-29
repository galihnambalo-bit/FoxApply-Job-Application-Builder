import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_profile.dart';
import '../../controllers/app_controller.dart';
import 'pdf_page_manager.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _ctrl = Get.find<AppController>();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (file == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      _ctrl.addScannedDoc(ScannedDocument(
        id: const Uuid().v4(),
        imagePath: file.path,
        name: 'Dokumen ${_ctrl.scannedDocs.length + 1}',
        order: _ctrl.scannedDocs.length,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Dokumen berhasil ditambahkan!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${e.toString().substring(0, e.toString().length.clamp(0, 100))}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickPDF() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );
      if (result == null || result.files.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
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
            content: Text('✅ ${result.files.length} file ditambahkan!'),
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

  @override
  Widget build(BuildContext context) {
    final isId = _ctrl.locale.languageCode == 'id';
    return Scaffold(
      appBar: AppBar(
        title: Text(isId ? 'Dokumen' : 'Documents'),
        actions: [
          // Tombol Refresh Manual
          Obx(() => _ctrl.scannedDocs.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: isId ? 'Refresh' : 'Refresh',
                  onPressed: () => setState(() {}),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          // Tombol upload
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(isId
                        ? 'Upload PDF (Ijazah, KTP, Sertifikat)'
                        : 'Upload PDF (Diploma, ID, Certificate)'),
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
                        onPressed: _isLoading
                            ? null
                            : () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: Text(isId ? 'Kamera' : 'Camera'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: Text(isId ? 'Galeri' : 'Gallery'),
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
              final docs = _ctrl.scannedDocs;
              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_open, size: 64,
                          color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text(
                        isId ? 'Belum ada dokumen' : 'No documents yet',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isId
                            ? 'Upload PDF atau ambil foto dokumen'
                            : 'Upload PDF or take photo of document',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final doc = docs[i];
                  final isPdf = doc.imagePath.toLowerCase().endsWith('.pdf');
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: (isPdf ? AppColors.error : AppColors.primary)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: isPdf
                            ? const Icon(Icons.picture_as_pdf,
                                color: AppColors.error)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(doc.imagePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image,
                                      color: AppColors.primary),
                                ),
                              ),
                      ),
                      title: Text(doc.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14)),
                      subtitle: Text(
                          isPdf ? 'File PDF' : isId ? 'Foto Dokumen' : 'Document Photo',
                          style: const TextStyle(fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.error),
                        onTap: () => Get.to(() => PdfPageManagerScreen(document: doc)),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => Get.to(() => PdfPageManagerScreen(document: doc)),
                      ),
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

  void _showDeleteDialog(BuildContext context, String id, bool isId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isId ? 'Hapus Dokumen?' : 'Delete Document?'),
        content: Text(isId
            ? 'Yakin ingin menghapus dokumen ini?'
            : 'Sure to delete this document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isId ? 'Batal' : 'Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              _ctrl.removeScannedDoc(id);
              Navigator.pop(context);
            },
            child: Text(isId ? 'Hapus' : 'Delete'),
          ),
        ],
      ),
    );
  }
}
