import 'dart:io';
import 'dart:typed_data';
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

  // Path file yang dihasilkan
  String? _letterPath;
  String? _cvPath;
  String? _docsPath;

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
      // 1. Generate Surat Lamaran
      setState(() => _status = isId ? '1/3 Membuat surat lamaran...' : '1/3 Generating cover letter...');
      final letterBytes = await LetterGenerator.generateCoverLetter(
        profile: _ctrl.userProfile,
        job: _ctrl.jobApplication,
        locale: locale,
      );

      // 2. Generate CV
      setState(() => _status = isId ? '2/3 Membuat CV...' : '2/3 Generating CV...');
      final cvBytes = await CVGenerator.generateCV(
        profile: _ctrl.userProfile,
        template: _ctrl.selectedTemplate,
        locale: locale,
      );

      // 3. Generate Dokumen
      setState(() => _status = isId ? '3/3 Memproses dokumen...' : '3/3 Processing documents...');
      final docsBytes = _ctrl.scannedDocs.isNotEmpty
          ? await PdfMerger.imagesToPdf(_ctrl.scannedDocs)
          : null;

      // Simpan semua file
      final dir = await getApplicationDocumentsDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final name = _ctrl.userProfile.fullName.replaceAll(' ', '_');

      _letterPath = '${dir.path}/Surat_Lamaran_${name}_$ts.pdf';
      _cvPath     = '${dir.path}/CV_${name}_$ts.pdf';

      await File(_letterPath!).writeAsBytes(letterBytes);
      await File(_cvPath!).writeAsBytes(cvBytes);

      if (docsBytes != null) {
        _docsPath = '${dir.path}/Dokumen_${name}_$ts.pdf';
        await File(_docsPath!).writeAsBytes(docsBytes);
      }

      // Tambah ke history
      _ctrl.addToHistory(_letterPath!);

      setState(() {
        _isGenerating = false;
        _isDone = true;
        _status = isId ? 'Paket lamaran siap! ✅' : 'Package ready! ✅';
      });

    } catch (e) {
      setState(() {
        _isGenerating = false;
        _status = 'Error: $e';
      });
    }
  }

  void _shareAll() {
    final files = [
      if (_letterPath != null) XFile(_letterPath!),
      if (_cvPath != null) XFile(_cvPath!),
      if (_docsPath != null) XFile(_docsPath!),
    ];
    if (files.isNotEmpty) {
      Share.shareXFiles(files, text: 'Paket Lamaran Kerja - FoxApply');
    }
  }

  void _downloadWithAd(String path, String label) {
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
            ? 'Tonton iklan singkat untuk download $label gratis!'
            : 'Watch a short ad to download $label for free!'),
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
                onComplete: () => OpenFilex.open(path),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(isId ? 'Paket Lamaran' : 'Application Package'),
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            // LOADING
            if (_isGenerating) ...[
              const SizedBox(height: 40),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text('🦊', style: TextStyle(fontSize: 50))),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 12),
              Text(_status, textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],

            // DONE
            if (_isDone) ...[
              const Icon(Icons.check_circle, color: AppColors.success, size: 60),
              const SizedBox(height: 12),
              Text(
                isId ? '🎉 Paket Lamaran Siap!' : '🎉 Package Ready!',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(color: AppColors.success),
              ),
              const SizedBox(height: 6),
              Text(
                isId
                    ? 'Semua file berhasil dibuat.\nKlik file di bawah untuk membuka.'
                    : 'All files created successfully.\nClick file below to open.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // File 1: Surat Lamaran
              if (_letterPath != null)
                _FileCard(
                  icon: Icons.description,
                  color: AppColors.secondary,
                  title: isId ? 'Surat Lamaran Kerja' : 'Cover Letter',
                  subtitle: isId ? 'Format professional, siap kirim' : 'Professional format, ready to send',
                  onOpen: () => _downloadWithAd(_letterPath!, isId ? 'Surat Lamaran' : 'Cover Letter'),
                  onShare: () => Share.shareXFiles([XFile(_letterPath!)]),
                ),
              const SizedBox(height: 12),

              // File 2: CV
              if (_cvPath != null)
                _FileCard(
                  icon: Icons.badge,
                  color: AppColors.primary,
                  title: 'Curriculum Vitae (CV)',
                  subtitle: isId ? 'Dengan foto dan data lengkap' : 'With photo and complete data',
                  onOpen: () => _downloadWithAd(_cvPath!, 'CV'),
                  onShare: () => Share.shareXFiles([XFile(_cvPath!)]),
                ),
              const SizedBox(height: 12),

              // File 3: Dokumen
              if (_docsPath != null)
                _FileCard(
                  icon: Icons.folder,
                  color: AppColors.success,
                  title: isId ? 'Dokumen Pendukung' : 'Supporting Documents',
                  subtitle: '${_ctrl.scannedDocs.length} ${isId ? "file terlampir" : "files attached"}',
                  onOpen: () => _downloadWithAd(_docsPath!, isId ? 'Dokumen' : 'Documents'),
                  onShare: () => Share.shareXFiles([XFile(_docsPath!)]),
                ),

              const SizedBox(height: 20),

              // Tombol Share Semua
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _shareAll,
                  icon: const Icon(Icons.share),
                  label: Text(isId ? '📤 Bagikan Semua File' : '📤 Share All Files'),
                  style: ElevatedButton.styleFrom(
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
              const SizedBox(height: 12),
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
    );
  }
}

class _FileCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onOpen;
  final VoidCallback onShare;

  const _FileCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onOpen,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.share, color: color, size: 20),
            onPressed: onShare,
          ),
          ElevatedButton(
            onPressed: onOpen,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('Buka', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
