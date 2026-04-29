import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/pdf_merger.dart';
import '../../../core/utils/ad_service.dart';
import '../../controllers/app_controller.dart';
import '../../widgets/banner_ad_widget.dart';

class GeneratePackageScreen extends StatefulWidget {
  const GeneratePackageScreen({super.key});
  @override
  State<GeneratePackageScreen> createState() => _GeneratePackageScreenState();
}

class _GeneratePackageScreenState extends State<GeneratePackageScreen> {
  final _ctrl = Get.find<AppController>();
  String _status = '';
  bool _isGenerating = false;
  bool _isDone = false;
  String? _outputPath;

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  Future<void> _startGeneration() async {
    setState(() { _isGenerating = true; _isDone = false; _outputPath = null; });
    final locale = _ctrl.locale.languageCode;
    final isId = locale == 'id';

    try {
      final path = await PackageGenerator.generateAll(
        profile: _ctrl.userProfile,
        job: _ctrl.jobApplication,
        docs: _ctrl.scannedDocs,
        locale: locale,
        template: _ctrl.selectedTemplate,
        onProgress: (s) {
          if (mounted) setState(() => _status = s);
        },
      );

      _ctrl.addToHistory(path);

      setState(() {
        _outputPath = path;
        _isGenerating = false;
        _isDone = true;
        _status = isId ? '✅ Paket lamaran siap!' : '✅ Package ready!';
      });

    } catch (e) {
      setState(() {
        _isGenerating = false;
        _status = 'Error: $e';
      });
    }
  }

  void _onDownload() {
    final isId = _ctrl.locale.languageCode == 'id';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Text('🎬', style: TextStyle(fontSize: 24)),
          SizedBox(width: 8),
          Text('Watch Ad'),
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
                onComplete: () {
                  if (_outputPath != null) OpenFilex.open(_outputPath!);
                },
                onSkipped: () {},
              );
            },
            icon: const Icon(Icons.play_circle, size: 18),
            label: Text(isId ? 'Tonton & Buka' : 'Watch & Open'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isId = _ctrl.locale.languageCode == 'id';
    final fileName = _outputPath?.split('/').last ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(isId ? 'Generate Paket' : 'Generate Package'),
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // LOADING
              if (_isGenerating) ...[
                Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🦊', style: TextStyle(fontSize: 55)),
                  ),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 14),
                Text(isId ? 'Sedang membuat paket...' : 'Generating package...',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(_status,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center),
              ],

              // DONE
              if (_isDone && _outputPath != null) ...[
                const Icon(Icons.check_circle, color: AppColors.success, size: 64),
                const SizedBox(height: 16),
                Text(
                  isId ? '🎉 Paket Lamaran Siap!' : '🎉 Package Ready!',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(color: AppColors.success),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isId
                      ? '1 PDF berisi:\n✅ Surat Lamaran\n✅ CV dengan foto\n✅ Dokumen pendukung'
                      : '1 PDF contains:\n✅ Cover Letter\n✅ CV with photo\n✅ Supporting documents',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(fileName,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                    textAlign: TextAlign.center),
                const SizedBox(height: 28),

                // Preview (gratis)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => OpenFilex.open(_outputPath!),
                    icon: const Icon(Icons.visibility),
                    label: Text(isId ? 'Preview PDF' : 'Preview PDF'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Download (dengan iklan)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _onDownload,
                    icon: const Icon(Icons.download),
                    label: Text(isId ? '🎬 Download PDF' : '🎬 Download PDF'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Share (gratis)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Share.shareXFiles(
                      [XFile(_outputPath!)],
                      text: isId
                          ? 'Paket Lamaran Kerja - FoxApply GAP Studio'
                          : 'Job Application Package - FoxApply GAP Studio',
                    ),
                    icon: const Icon(Icons.share),
                    label: Text(isId ? 'Bagikan via WhatsApp/Email' : 'Share via WhatsApp/Email'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _startGeneration,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(isId ? 'Generate Ulang' : 'Regenerate'),
                ),
              ],

              // ERROR
              if (!_isGenerating && !_isDone) ...[
                const Icon(Icons.error_outline, color: AppColors.error, size: 60),
                const SizedBox(height: 14),
                Text(_status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.error)),
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
