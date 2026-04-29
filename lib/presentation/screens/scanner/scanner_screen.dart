import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
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

  // ── SCAN DOKUMEN dengan edge detection ──────────────
  Future<void> _scanDocument() async {
    if (!mounted) return;

    // Request permission kamera
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        _showPermissionDialog();
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      // cunning_document_scanner - ada edge detection & garis hijau
      final pictures = await CunningDocumentScanner.getPictures(
        noOfPages: 10,           // max 10 halaman
        isGalleryImportAllowed: true, // bisa pilih dari galeri juga
      );

      if (pictures == null || pictures.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Simpan semua halaman yang di-scan
      for (int i = 0; i < pictures.length; i++) {
        _ctrl.addScannedDoc(ScannedDocument(
          id: const Uuid().v4(),
          imagePath: pictures[i],
          name: pictures.length > 1
              ? 'Scan ${_ctrl.scannedDocs.length + 1} (Hal ${i + 1})'
              : 'Scan ${_ctrl.scannedDocs.length + 1}',
          order: _ctrl.scannedDocs.length,
        ));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${pictures.length} halaman berhasil di-scan!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scan: ${e.toString().substring(0, e.toString().length.clamp(0, 100))}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // ── Upload dari Galeri ────────────────────────────
  Future<void> _pickGallery() async {
    if (!mounted) return;
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    setState(() => _isLoading = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (file == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      _ctrl.addScannedDoc(ScannedDocument(
        id: const Uuid().v4(),
        imagePath: file.path,
        name: 'Gambar ${_ctrl.scannedDocs.length + 1}',
        order: _ctrl.scannedDocs.length,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Gambar ditambahkan!'),
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

  // ── Upload PDF ────────────────────────────────────
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
          SnackBar(content: Text('Error PDF: $e'), backgroundColor: AppColors.error),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Izin Kamera Diperlukan'),
        content: const Text(
            'Izin kamera diperlukan untuk scan dokumen. '
            'Buka pengaturan untuk mengizinkan.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
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

  @override
  Widget build(BuildContext context) {
    final isId = _ctrl.locale.languageCode == 'id';
    return Scaffold(
      appBar: AppBar(
        title: Text(isId ? 'Dokumen' : 'Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tombol aksi
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 4, offset: Offset(0, 2),
              )],
            ),
            child: Column(
              children: [
                // SCAN - fitur utama dengan edge detection
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _scanDocument,
                    icon: const Icon(Icons.document_scanner, size: 20),
                    label: Text(
                      isId
                          ? '📷 Scan Dokumen (Deteksi Otomatis)'
                          : '📷 Scan Document (Auto Detect)',
                      style: const TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Upload PDF
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _pickPDF,
                        icon: const Icon(Icons.picture_as_pdf,
                            color: Color(0xFFC62828), size: 18),
                        label: const Text('Upload PDF',
                            style: TextStyle(color: Color(0xFFC62828))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFC62828)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Galeri
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _pickGallery,
                        icon: const Icon(Icons.photo_library,
                            color: AppColors.accent, size: 18),
                        label: Text(isId ? 'Galeri' : 'Gallery',
                            style: const TextStyle(color: AppColors.accent)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.accent),
                        ),
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
                            ? 'Scan dokumen atau upload PDF\ndi atas'
                            : 'Scan document or upload PDF\nabove',
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
                      onTap: () => Get.to(
                          () => PdfPageManagerScreen(document: doc)),
                      leading: Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: (isPdf
                                  ? const Color(0xFFC62828)
                                  : AppColors.primary)
                              .withValues(alpha: 0.1),
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
                                      Icons.image,
                                      color: AppColors.primary),
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
                                ? 'Foto/Scan • Ketuk untuk kelola'
                                : 'Photo/Scan • Tap to manage',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chevron_right,
                              color: AppColors.textSecondary, size: 20),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error, size: 20),
                            onPressed: () =>
                                _confirmDelete(context, doc.id, isId),
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
        title: Text(isId ? 'Hapus Dokumen?' : 'Delete Document?'),
        content: Text(isId ? 'Yakin hapus ini?' : 'Sure to delete?'),
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
