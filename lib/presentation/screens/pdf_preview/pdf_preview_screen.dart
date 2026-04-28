// lib/presentation/screens/pdf_preview/pdf_preview_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/cv_generator.dart';
import '../../../core/utils/letter_generator.dart';
import '../../../core/utils/pdf_merger.dart';
import '../../controllers/app_controller.dart';
import 'package:foxapply/l10n/app_localizations.dart';

class GeneratePackageScreen extends StatefulWidget {
  const GeneratePackageScreen({super.key});

  @override
  State<GeneratePackageScreen> createState() => _GeneratePackageScreenState();
}

class _GeneratePackageScreenState extends State<GeneratePackageScreen> {
  final _ctrl = Get.find<AppController>();
  String _status = '';
  String? _outputPath;
  bool _isGenerating = false;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  Future<void> _startGeneration() async {
    setState(() {
      _isGenerating = true;
      _isDone = false;
    });

    final l = AppLocalizations.of(context)!;
    final locale = _ctrl.locale.languageCode;

    try {
      setState(() => _status = locale == 'id'
          ? 'Membuat CV...'
          : 'Generating CV...');

      final cvBytes = await CVGenerator.generateCV(
        profile: _ctrl.userProfile,
        template: _ctrl.selectedTemplate,
        locale: locale,
      );

      setState(() => _status = locale == 'id'
          ? 'Membuat surat lamaran...'
          : 'Generating cover letter...');

      final letterBytes = await LetterGenerator.generateCoverLetter(
        profile: _ctrl.userProfile,
        job: _ctrl.jobApplication,
        locale: locale,
      );

      setState(() => _status = locale == 'id'
          ? 'Memproses dokumen scan...'
          : 'Processing scanned documents...');

      final docsBytes = await PdfMerger.imagesToPdf(_ctrl.scannedDocs);

      setState(() => _status = locale == 'id'
          ? 'Menggabungkan file PDF...'
          : 'Merging PDF files...');

      final path = await PackageGenerator.generateFinalPackage(
        pdfPages: [letterBytes, cvBytes, docsBytes],
        fileName:
            'FoxApply_${_ctrl.userProfile.fullName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      setState(() {
        _outputPath = path;
        _isGenerating = false;
        _isDone = true;
        _status = l.packageReady;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.finalPackage)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isGenerating) ...[
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🦊', style: TextStyle(fontSize: 60)),
                  ),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(l.generating,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(_status,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center),
              ],
              if (_isDone && _outputPath != null) ...[
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🦊', style: TextStyle(fontSize: 60)),
                  ),
                ),
                const SizedBox(height: 24),
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 48),
                const SizedBox(height: 12),
                Text(l.packageReady,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: AppColors.success)),
                const SizedBox(height: 8),
                Text(
                  _outputPath!.split('/').last,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => OpenFilex.open(_outputPath!),
                    icon: const Icon(Icons.visibility),
                    label: Text(l.preview),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Share.shareXFiles(
                      [XFile(_outputPath!)],
                      text: 'FoxApply - Job Application Package',
                    ),
                    icon: const Icon(Icons.share),
                    label: Text(l.share),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _startGeneration,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Regenerate'),
                ),
              ],
              if (!_isGenerating && !_isDone) ...[
                const Icon(Icons.error, color: AppColors.error, size: 60),
                const SizedBox(height: 16),
                Text(_status, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _startGeneration,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
