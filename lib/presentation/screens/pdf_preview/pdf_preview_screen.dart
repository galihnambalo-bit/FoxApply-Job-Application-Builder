import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  double _progress = 0;

  // Inline banner saat loading
  BannerAd? _loadingBanner;
  bool _loadingBannerReady = false;

  @override
  void initState() {
    super.initState();
    _loadInlineBanner();
    _startGeneration();
  }

  void _loadInlineBanner() {
    final banner = BannerAd(
      adUnitId: AdService.instance.bannerAdUnitId,
      size: AdSize.mediumRectangle, // 300x250 - lebih besar dan jelas
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() {
            _loadingBanner = ad as BannerAd;
            _loadingBannerReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    banner.load();
    _loadingBanner = banner;
  }

  void _setProgress(double val, String msg) {
    if (mounted) setState(() { _progress = val; _status = msg; });
  }

  Future<void> _startGeneration() async {
    setState(() {
      _isGenerating = true;
      _isDone = false;
      _outputPath = null;
      _progress = 0;
    });

    final locale = _ctrl.locale.languageCode;
    final isId = locale == 'id';

    try {
      _setProgress(0.05, isId ? 'Mempersiapkan data...' : 'Preparing data...');
      await Future.delayed(const Duration(milliseconds: 800));

      _setProgress(0.15, isId ? 'Membuat halaman cover...' : 'Creating cover page...');
      await Future.delayed(const Duration(milliseconds: 600));

      _setProgress(0.30, isId ? '✉️ Membuat surat lamaran...' : '✉️ Generating cover letter...');
      await Future.delayed(const Duration(milliseconds: 500));

      _setProgress(0.50, isId ? '📋 Membuat CV dengan foto...' : '📋 Generating CV with photo...');
      await Future.delayed(const Duration(milliseconds: 600));

      _setProgress(0.70, isId ? '📄 Memproses dokumen lampiran...' : '📄 Processing attached documents...');
      await Future.delayed(const Duration(milliseconds: 500));

      _setProgress(0.85, isId ? '🔗 Menggabungkan semua file...' : '🔗 Merging all files...');

      final path = await PackageGenerator.generateAll(
        profile: _ctrl.userProfile,
        job: _ctrl.jobApplication,
        docs: _ctrl.scannedDocs,
        locale: locale,
        template: _ctrl.selectedTemplate,
        onProgress: (s) => _setProgress(_progress, s),
      );

      _setProgress(0.95, isId ? 'Menyimpan file PDF...' : 'Saving PDF file...');
      await Future.delayed(const Duration(milliseconds: 500));

      _ctrl.addToHistory(path);

      _setProgress(1.0, isId ? '✅ Selesai!' : '✅ Done!');
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _outputPath = path;
        _isGenerating = false;
        _isDone = true;
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
  void dispose() {
    _loadingBanner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isId = _ctrl.locale.languageCode == 'id';

    return Scaffold(
      appBar: AppBar(
        title: Text(isId ? 'Generate Paket' : 'Generate Package'),
        automaticallyImplyLeading: !_isGenerating,
      ),
      // Banner kecil selalu ada di bawah
      bottomNavigationBar: const BannerAdWidget(),
      body: _isGenerating
          ? _buildLoadingView(isId)
          : _isDone
              ? _buildDoneView(isId)
              : _buildErrorView(isId),
    );
  }

  // ── LOADING VIEW dengan iklan ──────────────────────────
  Widget _buildLoadingView(bool isId) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Fox animasi
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🦊', style: TextStyle(fontSize: 50)),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  isId ? 'Sedang Membuat Paket Lamaran...' : 'Generating Application Package...',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  isId
                      ? 'Surat + CV + Dokumen → 1 PDF'
                      : 'Letter + CV + Documents → 1 PDF',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 20),

                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_status,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13)),
                        Text('${(_progress * 100).toInt()}%',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 12,
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Steps progress
                _buildStepIndicator(isId),
                const SizedBox(height: 24),

                // IKLAN MEDIUM RECTANGLE saat loading
                // Muncul natural sambil user nunggu
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: _loadingBannerReady && _loadingBanner != null
                      ? SizedBox(
                          width: _loadingBanner!.size.width.toDouble(),
                          height: _loadingBanner!.size.height.toDouble(),
                          child: AdWidget(ad: _loadingBanner!),
                        )
                      : Container(
                          width: double.infinity,
                          height: 250,
                          color: AppColors.background,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                  color: AppColors.primary, strokeWidth: 2),
                              const SizedBox(height: 10),
                              Text(
                                isId ? 'Memuat iklan...' : 'Loading ad...',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(bool isId) {
    final steps = isId
        ? ['Cover', 'Surat', 'CV', 'Dokumen', 'Selesai']
        : ['Cover', 'Letter', 'CV', 'Docs', 'Done'];
    final currentStep = (_progress * steps.length).floor().clamp(0, steps.length - 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: steps.asMap().entries.map((e) {
        final done = e.key < currentStep;
        final active = e.key == currentStep;
        return Row(
          children: [
            Column(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? AppColors.success
                      : active
                          ? AppColors.primary
                          : AppColors.divider,
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : active
                          ? const SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                          : Text('${e.key + 1}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 4),
              Text(e.value,
                  style: TextStyle(
                      fontSize: 9,
                      color: done || active
                          ? AppColors.primary
                          : AppColors.textSecondary)),
            ]),
            if (e.key < steps.length - 1)
              Container(
                width: 24, height: 2, margin: const EdgeInsets.only(bottom: 18),
                color: done ? AppColors.success : AppColors.divider,
              ),
          ],
        );
      }).toList(),
    );
  }

  // ── DONE VIEW ────────────────────────────────────────
  Widget _buildDoneView(bool isId) {
    final fileName = _outputPath?.split('/').last ?? '';
    final fileSizeKB = _outputPath != null
        ? (File(_outputPath!).lengthSync() / 1024).toStringAsFixed(0)
        : '0';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Icon(Icons.check_circle, color: AppColors.success, size: 70),
          const SizedBox(height: 16),
          Text(
            isId ? '🎉 Paket Lamaran Siap!' : '🎉 Package Ready!',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: AppColors.success),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Info isi PDF
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isId ? '📦 Isi 1 PDF:' : '📦 1 PDF Contains:',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                _checkItem('✉️ ${isId ? "Surat Lamaran Kerja" : "Cover Letter"}'),
                _checkItem('📋 Curriculum Vitae (CV)'),
                if (_ctrl.scannedDocs.isNotEmpty)
                  _checkItem('📄 ${isId ? "Dokumen Pendukung (${_ctrl.scannedDocs.length} file)" : "Supporting Docs (${_ctrl.scannedDocs.length} files)"}'),
                const SizedBox(height: 8),
                Text(
                  isId ? 'Ukuran: $fileSizeKB KB' : 'Size: $fileSizeKB KB',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Preview gratis
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => OpenFilex.open(_outputPath!),
              icon: const Icon(Icons.visibility),
              label: Text(isId ? 'Preview PDF' : 'Preview PDF'),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          const SizedBox(height: 10),

          // Download dengan iklan
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _onDownload,
              icon: const Icon(Icons.download),
              label: Text(isId ? '🎬 Download PDF' : '🎬 Download PDF'),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          const SizedBox(height: 10),

          // Share gratis
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
              label: Text(isId
                  ? '📤 Bagikan via WhatsApp/Email'
                  : '📤 Share via WhatsApp/Email'),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          const SizedBox(height: 10),

          TextButton.icon(
            onPressed: _startGeneration,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(isId ? 'Generate Ulang' : 'Regenerate'),
          ),
        ],
      ),
    );
  }

  Widget _checkItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        const Icon(Icons.check_circle, color: AppColors.success, size: 16),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12)),
      ]),
    );
  }

  // ── ERROR VIEW ───────────────────────────────────────
  Widget _buildErrorView(bool isId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 64),
            const SizedBox(height: 14),
            Text(_status, textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _startGeneration,
              icon: const Icon(Icons.refresh),
              label: Text(isId ? 'Coba Lagi' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
