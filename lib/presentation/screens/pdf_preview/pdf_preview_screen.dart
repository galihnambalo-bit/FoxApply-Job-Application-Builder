import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/cv_generator.dart';
import '../../../core/utils/letter_generator.dart';
import '../../../core/utils/pdf_merger.dart';
import '../../../core/utils/ad_service.dart';
import '../../controllers/app_controller.dart';
import '../../widgets/banner_ad_widget.dart';
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
    setState(() { _isGenerating = true; _isDone = false; });
    final locale = _ctrl.locale.languageCode;
    final isId = locale == 'id';

    try {
      setState(() => _status = isId ? 'Membuat CV...' : 'Generating CV...');
      final cvBytes = await CVGenerator.generateCV(
        profile: _ctrl.userProfile,
        template: _ctrl.selectedTemplate,
        locale: locale,
      );

      setState(() => _status = isId ? 'Membuat surat lamaran...' : 'Generating cover letter...');
      final letterBytes = await LetterGenerator.generateCoverLetter(
        profile: _ctrl.userProfile,
        job: _ctrl.jobApplication,
        locale: locale,
      );

      setState(() => _status = isId ? 'Memproses dokumen...' : 'Processing documents...');
      final docsBytes = await PdfMerger.imagesToPdf(_ctrl.scannedDocs);

      setState(() => _status = isId ? 'Menggabungkan PDF...' : 'Merging PDF...');

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'FoxApply_${_ctrl.userProfile.fullName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final outPath = '${dir.path}/$fileName';
      final file = File(outPath);
      await file.writeAsBytes(cvBytes);

      _ctrl.addToHistory(outPath);

      setState(() {
        _outputPath = outPath;
        _isGenerating = false;
        _isDone = true;
        _status = isId ? 'Paket siap!' : 'Package ready!';
      });
    } catch (e) {
      setState(() { _isGenerating = false; _status = 'Error: $e'; });
    }
  }

  void _onSavePressed() {
    final isId = _ctrl.locale.languageCode == 'id';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Text('🎬', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(isId ? 'Tonton Iklan' : 'Watch Ad'),
        ]),
        content: Text(isId
            ? 'Tonton iklan singkat untuk download PDF gratis!'
            : 'Watch a short ad to download PDF for free!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isId ? 'Batal' : 'Cancel',
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              AdService.instance.showRewardedAd(
                onComplete: () { if (_outputPath != null) OpenFilex.open(_outputPath!); },
                onSkipped: () {},
              );
            },
            icon: const Icon(Icons.play_circle, size: 18),
            label: Text(isId ? 'Tonton & Unduh' : 'Watch & Download'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isId = _ctrl.locale.languageCode == 'id';
    return Scaffold(
      appBar: AppBar(title: Text(isId ? 'Paket Lamaran' : 'Application Package')),
      bottomNavigationBar: const BannerAdWidget(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isGenerating) ...[
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Text('🦊', style: TextStyle(fontSize: 60))),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(isId ? 'Membuat paket...' : 'Generating package...',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(_status, style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center),
              ],
              if (_isDone && _outputPath != null) ...[
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Text('🦊', style: TextStyle(fontSize: 60))),
                ),
                const SizedBox(height: 16),
                const Icon(Icons.check_circle, color: AppColors.success, size: 48),
                const SizedBox(height: 12),
                Text(isId ? 'Paket siap!' : 'Package ready!',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: AppColors.success)),
                const SizedBox(height: 32),
                SizedBox(width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => OpenFilex.open(_outputPath!),
                    icon: const Icon(Icons.visibility),
                    label: Text(isId ? 'Preview' : 'Preview'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _onSavePressed,
                    icon: const Icon(Icons.download),
                    label: Text(isId ? '🎬 Unduh PDF' : '🎬 Download PDF'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Share.shareXFiles(
                      [XFile(_outputPath!)],
                      text: 'FoxApply - Job Application Package',
                    ),
                    icon: const Icon(Icons.share),
                    label: Text(isId ? 'Bagikan' : 'Share'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _startGeneration,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(isId ? 'Buat Ulang' : 'Regenerate'),
                ),
              ],
              if (!_isGenerating && !_isDone) ...[
                const Icon(Icons.error_outline, color: AppColors.error, size: 60),
                const SizedBox(height: 16),
                Text(_status, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _startGeneration,
                  icon: const Icon(Icons.refresh),
                  label: Text(isId ? 'Coba Lagi' : 'Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
