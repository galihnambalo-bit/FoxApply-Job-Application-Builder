// lib/presentation/screens/scanner/scanner_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_profile.dart';
import '../../controllers/app_controller.dart';
import 'package:foxapply/l10n/app_localizations.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _ctrl = Get.find<AppController>();
  final _picker = ImagePicker();

  Future<void> _scanDocument(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (file == null) return;

    // Crop the image
    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: AppLocalizations.of(context)!.cropAdjust,
          toolbarColor: AppColors.secondary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.primary,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
      ],
    );

    if (cropped == null) return;

    final doc = ScannedDocument(
      id: const Uuid().v4(),
      imagePath: cropped.path,
      name: 'Document ${_ctrl.scannedDocs.length + 1}',
      order: _ctrl.scannedDocs.length,
    );

    _ctrl.addScannedDoc(doc);
  }

  void _showFilterDialog(ScannedDocument doc) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.applyFilter),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DocumentFilter.values.map((f) {
            String label;
            switch (f) {
              case DocumentFilter.original:
                label = l.filterOriginal;
                break;
              case DocumentFilter.blackAndWhite:
                label = l.filterBW;
                break;
              case DocumentFilter.enhanced:
                label = l.filterEnhanced;
                break;
            }
            return RadioListTile<DocumentFilter>(
              value: f,
              groupValue: doc.filter,
              onChanged: (v) {
                doc.filter = v!;
                
                _ctrl.saveScannedDocs();
                Navigator.pop(context);
              },
              title: Text(label),
              activeColor: AppColors.primary,
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.scanner),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context),
          ),
        ],
      ),
      body: Obx(() {
        if (_ctrl.scannedDocs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.document_scanner_outlined,
                    size: 80, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(l.scannedDocs,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(l.addDocument,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                _buildScanButtons(l),
              ],
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _ctrl.scannedDocs.length,
                onReorder: _ctrl.reorderDocs,
                itemBuilder: (_, i) {
                  final doc = _ctrl.scannedDocs[i];
                  return _DocumentCard(
                    key: ValueKey(doc.id),
                    doc: doc,
                    onFilter: () => _showFilterDialog(doc),
                    onDelete: () => _ctrl.removeScannedDoc(doc.id),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildScanButtons(l),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildScanButtons(AppLocalizations l) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _scanDocument(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: Text(l.takePhoto),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _scanDocument(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: Text(l.chooseGallery),
          ),
        ),
      ],
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Scanner Tips'),
        content: const Text(
            '• Take photo in good lighting\n'
            '• Lay document flat\n'
            '• Use crop to adjust borders\n'
            '• B&W filter for cleaner scans\n'
            '• Drag items to reorder'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final ScannedDocument doc;
  final VoidCallback onFilter;
  final VoidCallback onDelete;

  const _DocumentCard({
    super.key,
    required this.doc,
    required this.onFilter,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(doc.imagePath),
            width: 56,
            height: 72,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.image_not_supported),
          ),
        ),
        title: Text(doc.name),
        subtitle: Text(_filterLabel(doc.filter)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.filter, color: AppColors.accent),
              onPressed: onFilter,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: onDelete,
            ),
            const Icon(Icons.drag_handle, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  String _filterLabel(DocumentFilter f) {
    switch (f) {
      case DocumentFilter.original: return 'Original';
      case DocumentFilter.blackAndWhite: return 'B&W';
      case DocumentFilter.enhanced: return 'Enhanced';
    }
  }
}

// Extension on AppController for saving
extension AppControllerExt on AppController {
  void saveScannedDocs() {
    // Trigger storage save
    updateUserProfile(userProfile);
  }
}
