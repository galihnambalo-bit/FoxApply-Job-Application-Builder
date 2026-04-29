import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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

  // Request permission dulu sebelum akses kamera/galeri
  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Izin Kamera'),
            content: const Text(
                'Izin kamera diperlukan untuk scan dokumen. '
                'Buka pengaturan untuk mengizinkan akses kamera.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Buka Pengaturan'),
              ),
            ],
          ),
        );
      }
      return false;
    }
    return status.isGranted;
  }

  Future<bool> _requestStoragePermission() async {
    // Android 13+ pakai READ_MEDIA_IMAGES
    if (Platform.isAndroid) {
      final photos = await Permission.photos.request();
      if (photos.isGranted) return true;
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }
    return true;
  }

  Future<void> _pickCamera() async {
    if (!mounted) return;
    
    // Request permission kamera
    final granted = await _requestCameraPermission();
    if (!granted) return;

    setState(() => _isLoading = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
        preferredCameraDevice: CameraDevice.rear,
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
            content: Text('✅ Foto berhasil ditambahkan!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error kamera: ${e.toString().length > 80 ? e.toString().substring(0, 80) : e}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickGallery() async {
    if (!mounted) return;

    final granted = await _requestStoragePermission();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin galeri diperlukan'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
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
            content: Text('✅ Foto berhasil ditambahkan!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error galeri: ${e.toString().length > 80 ? e.toString().substring(0, 80) : e}'),
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
            content: Text('✅ ${result.files.length} PDF ditambahkan!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error PDF: $e'),
            backgroundColor: AppColors.error,
          ),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tombol tambah
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4, offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Upload PDF
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(isId
                        ? 'Upload PDF (Ijazah, KTP, Sertifikat)'
                        : 'Upload PDF (Diploma, ID, Certificate)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _pickCamera,
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: Text(isId ? '📷 Kamera' : '📷 Camera'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _pickGallery,
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: Text(isId ? '🖼️ Galeri' : '🖼️ Gallery'),
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
                      const Text('📂', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 12),
                      Text(
                        isId ? 'Belum ada dokumen' : 'No documents yet',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isId
                            ? 'Upload PDF atau foto dokumenmu di atas'
                            : 'Upload PDF or take photo above',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final doc = docs[i];
                  final isPdf = doc.imagePath.toLowerCase().endsWith('.pdf');
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => Get.to(() => PdfPageManagerScreen(document: doc)),
                      leading: Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: (isPdf
                              ? const Color(0xFFC62828)
                              : AppColors.primary).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: isPdf
                            ? const Icon(Icons.picture_as_pdf,
                                color: Color(0xFFC62828))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(doc.imagePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image, color: AppColors.primary),
                                ),
                              ),
                      ),
                      title: Text(doc.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14)),
                      subtitle: Text(
                        isPdf
                            ? 'PDF • ${isId ? "Ketuk untuk kelola" : "Tap to manage"}'
                            : isId
                                ? 'Foto • Ketuk untuk kelola'
                                : 'Photo • Tap to manage',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chevron_right,
                              color: AppColors.textSecondary),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error, size: 20),
                            onPressed: () => _confirmDelete(context, doc.id, isId),
                          ),
                        ],
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

  void _confirmDelete(BuildContext context, String id, bool isId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isId ? 'Hapus?' : 'Delete?'),
        content: Text(isId
            ? 'Yakin hapus dokumen ini?'
            : 'Sure to delete this document?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isId ? 'Batal' : 'Cancel')),
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
