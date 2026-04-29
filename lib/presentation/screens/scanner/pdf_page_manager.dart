import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_profile.dart';
import '../../controllers/app_controller.dart';

class PdfPageManagerScreen extends StatefulWidget {
  final ScannedDocument document;
  const PdfPageManagerScreen({super.key, required this.document});
  @override
  State<PdfPageManagerScreen> createState() => _PdfPageManagerScreenState();
}

class _PdfPageManagerScreenState extends State<PdfPageManagerScreen> {
  final _ctrl = Get.find<AppController>();
  
  // Untuk PDF: tampilkan info halaman
  // Untuk gambar: tampilkan preview + opsi filter

  @override
  Widget build(BuildContext context) {
    final isId = _ctrl.locale.languageCode == 'id';
    final isPdf = widget.document.imagePath.toLowerCase().endsWith('.pdf');

    return Scaffold(
      appBar: AppBar(
        title: Text(isId ? 'Kelola Dokumen' : 'Manage Document'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            tooltip: isId ? 'Hapus dokumen ini' : 'Delete this document',
            onPressed: () => _deleteDoc(context, isId),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info dokumen
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Icon(
                    isPdf ? Icons.picture_as_pdf : Icons.image,
                    color: isPdf ? AppColors.error : AppColors.primary,
                    size: 40,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.document.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(isPdf ? 'File PDF' : isId ? 'Foto Dokumen' : 'Document Photo',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Preview gambar
            if (!isPdf) ...[
              Text(isId ? 'Preview:' : 'Preview:',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(widget.document.imagePath),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, size: 60)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Filter options
              Text(isId ? 'Filter:' : 'Filter:',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: DocumentFilter.values.map((f) {
                  final label = switch(f) {
                    DocumentFilter.original => isId ? 'Asli' : 'Original',
                    DocumentFilter.blackAndWhite => 'B&W',
                    DocumentFilter.enhanced => isId ? 'Tajam' : 'Enhanced',
                  };
                  final selected = widget.document.filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                          color: selected ? Colors.white : AppColors.textPrimary),
                      onSelected: (_) {
                        widget.document.filter = f;
                        _ctrl.scannedDocs.refresh();
                        _ctrl.saveDocsToStorage();
                        setState(() {});
                      },
                    ),
                  );
                }).toList(),
              ),
            ],

            if (isPdf) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline, color: AppColors.error, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    isId
                        ? 'File PDF akan dilampirkan langsung dalam paket lamaran.'
                        : 'PDF file will be attached directly in the application package.',
                    style: const TextStyle(fontSize: 12),
                  )),
                ]),
              ),
              const Spacer(),
            ],

            // Tombol hapus
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _deleteDoc(context, isId),
                icon: const Icon(Icons.delete),
                label: Text(isId ? 'Hapus Dokumen Ini' : 'Delete This Document'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteDoc(BuildContext context, bool isId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isId ? 'Hapus Dokumen?' : 'Delete Document?'),
        content: Text(isId
            ? 'Yakin hapus "${widget.document.name}"?'
            : 'Sure to delete "${widget.document.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text(isId ? 'Batal' : 'Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              _ctrl.removeScannedDoc(widget.document.id);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isId ? '✅ Dokumen dihapus' : '✅ Document deleted'),
                    backgroundColor: AppColors.success),
              );
            },
            child: Text(isId ? 'Hapus' : 'Delete'),
          ),
        ],
      ),
    );
  }
}

extension AppControllerDocs on AppController {
  void saveDocsToStorage() {
    // trigger save
    updateUserProfile(userProfile);
  }
}
