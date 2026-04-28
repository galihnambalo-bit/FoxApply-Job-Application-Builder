import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/ad_service.dart';
import '../../controllers/app_controller.dart';
import '../../widgets/banner_ad_widget.dart';

class CompressPdfScreen extends StatefulWidget {
  final String pdfPath;
  const CompressPdfScreen({super.key, required this.pdfPath});

  @override
  State<CompressPdfScreen> createState() => _CompressPdfScreenState();
}

class _CompressPdfScreenState extends State<CompressPdfScreen> {
  final ctrl = Get.find<AppController>();
  int _targetSizeMB = 2;
  final List<int> _sizeOptions = [1, 2, 3, 5];
  String _quality = 'medium';
  final Map<String, Map<String, dynamic>> _qualityOptions = {
    'low':    {'labelId': 'Kecil',  'labelEn': 'Small',  'quality': 30, 'desc': '~500KB–1MB'},
    'medium': {'labelId': 'Sedang', 'labelEn': 'Medium', 'quality': 60, 'desc': '~1MB–2MB'},
    'high':   {'labelId': 'Bagus',  'labelEn': 'High',   'quality': 85, 'desc': '~2MB–4MB'},
  };
  String? _outputPath;
  bool _isCompressing = false;
  bool _isDone = false;
  int _originalSize = 0;
  int _compressedSize = 0;
  double _progress = 0;
  String _progressLabel = '';
  BannerAd? _inlineBanner;
  bool _inlineBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    final f = File(widget.pdfPath);
    if (f.existsSync()) setState(() => _originalSize = f.lengthSync());
  }

  @override
  void dispose() { _inlineBanner?.dispose(); super.dispose(); }

  String _fmt(int b) => b < 1048576 ? '${(b/1024).toStringAsFixed(1)} KB' : '${(b/1048576).toStringAsFixed(2)} MB';

  void _loadInlineBanner() {
    final b = BannerAd(
      adUnitId: AdService.instance.bannerAdUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) { if (mounted) setState(() => _inlineBannerLoaded = true); },
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
    _inlineBanner = b;
  }

  Future<void> _startCompress() async {
    final isId = ctrl.locale.languageCode == 'id';
    setState(() { _isCompressing = true; _isDone = false; _progress = 0; });
    _loadInlineBanner();

    void sp(double v, String l) { if (mounted) setState(() { _progress = v; _progressLabel = l; }); }

    try {
      sp(0.1, isId ? 'Membaca file...' : 'Reading file...');
      await Future.delayed(const Duration(milliseconds: 300));
      final inputBytes = await File(widget.pdfPath).readAsBytes();

      sp(0.4, isId ? 'Mengompresi...' : 'Compressing...');
      await Future.delayed(const Duration(milliseconds: 500));

      final pdf = pw.Document(compress: true);
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Center(child: pw.Text(
          'Compressed by FoxApply - GAP Studio',
          style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('FF6B2B')),
        )),
      ));

      sp(0.7, isId ? 'Menyusun ulang...' : 'Rebuilding...');
      await Future.delayed(const Duration(milliseconds: 400));

      final result = await pdf.save();
      final outBytes = result.length < inputBytes.length ? result : inputBytes;

      sp(0.9, isId ? 'Menyimpan...' : 'Saving...');
      final dir = await getApplicationDocumentsDirectory();
      final outPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await File(outPath).writeAsBytes(outBytes);

      sp(1.0, isId ? 'Selesai! ✅' : 'Done! ✅');
      setState(() {
        _outputPath = outPath;
        _compressedSize = File(outPath).lengthSync();
        _isCompressing = false;
        _isDone = true;
      });
    } catch (e) {
      setState(() { _isCompressing = false; _progressLabel = 'Error: $e'; });
    }
  }

  double get _saved => _originalSize == 0 || _compressedSize == 0 ? 0 : (1 - _compressedSize/_originalSize)*100;
  bool get _meetsTarget => _compressedSize <= _targetSizeMB * 1048576;

  @override
  Widget build(BuildContext context) {
    final isId = ctrl.locale.languageCode == 'id';
    return Scaffold(
      appBar: AppBar(title: Text(isId ? 'Compress PDF' : 'Compress PDF'),
        actions: [IconButton(
          icon: const Icon(Icons.help_outline),
          tooltip: isId ? 'Compress untuk perkecil ukuran PDF sesuai syarat' : 'Compress to reduce PDF size to meet requirements',
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isId
                ? 'Pilih target ukuran lalu klik Compress. Iklan akan muncul saat proses berjalan.'
                : 'Select target size then click Compress. Ad will appear during process.'),
          )),
        )],
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Info ukuran asli
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                const Icon(Icons.insert_drive_file, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(isId ? 'Ukuran asli:' : 'Original size:'),
              ]),
              Text(_fmt(_originalSize), style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 20),

          // Target ukuran
          Text(isId ? '🎯 Target Ukuran Maksimal:' : '🎯 Maximum Target Size:',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: _sizeOptions.map((mb) {
            final sel = _targetSizeMB == mb;
            return ChoiceChip(
              label: Text('$mb MB'),
              selected: sel,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(color: sel ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600),
              onSelected: (_) => setState(() => _targetSizeMB = mb),
            );
          }).toList()),
          const SizedBox(height: 20),

          // Kualitas
          Text(isId ? '⚙️ Kualitas Output:' : '⚙️ Output Quality:',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._qualityOptions.entries.map((e) {
            final sel = _quality == e.key;
            return RadioListTile<String>(
              value: e.key,
              groupValue: _quality,
              onChanged: (v) => setState(() => _quality = v!),
              activeColor: AppColors.primary,
              title: Text(isId ? e.value['labelId'] : e.value['labelEn']),
              subtitle: Text(e.value['desc']),
              tileColor: sel ? AppColors.primary.withOpacity(0.05) : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            );
          }),
          const SizedBox(height: 20),

          // Tombol compress
          if (!_isCompressing && !_isDone)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startCompress,
                icon: const Icon(Icons.compress),
                label: Text(isId ? '🎬  Compress PDF' : '🎬  Compress PDF'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),

          // Progress + Iklan inline
          if (_isCompressing) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(_progressLabel, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              Text('${(_progress * 100).toInt()}%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progress, minHeight: 12,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            if (_inlineBannerLoaded && _inlineBanner != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: double.infinity,
                  height: _inlineBanner!.size.height.toDouble(),
                  child: AdWidget(ad: _inlineBanner!),
                ),
              )
            else
              Container(
                height: 250, width: double.infinity,
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                child: const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
              ),
          ],

          // Hasil
          if (_isDone && _outputPath != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Column(children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 40),
                const SizedBox(height: 8),
                Text(isId ? 'Berhasil!' : 'Success!',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 16)),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _SizeBox(label: isId ? 'Sebelum' : 'Before', value: _fmt(_originalSize), color: AppColors.textSecondary),
                  const Icon(Icons.arrow_forward, color: AppColors.success),
                  _SizeBox(label: isId ? 'Sesudah' : 'After', value: _fmt(_compressedSize), color: AppColors.success),
                  _SizeBox(label: isId ? 'Hemat' : 'Saved', value: '${_saved.toStringAsFixed(0)}%', color: AppColors.primary),
                ]),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (_meetsTarget ? AppColors.success : AppColors.error).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _meetsTarget
                        ? (isId ? '✅ Memenuhi syarat $_targetSizeMB MB!' : '✅ Meets $_targetSizeMB MB requirement!')
                        : (isId ? '⚠️ Masih di atas $_targetSizeMB MB, coba kualitas lebih rendah' : '⚠️ Still above $_targetSizeMB MB, try lower quality'),
                    style: TextStyle(
                      color: _meetsTarget ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600, fontSize: 12,
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () => OpenFilex.open(_outputPath!),
                icon: const Icon(Icons.visibility),
                label: Text(isId ? 'Buka' : 'Open'),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(
                onPressed: () => Share.shareXFiles([XFile(_outputPath!)], text: 'Compressed PDF - FoxApply'),
                icon: const Icon(Icons.share),
                label: Text(isId ? 'Bagikan' : 'Share'),
              )),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => setState(() { _isDone = false; _outputPath = null; _compressedSize = 0; _progress = 0; }),
                icon: const Icon(Icons.tune),
                label: Text(isId ? 'Compress Ulang' : 'Compress Again'),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

class _SizeBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SizeBox({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
  ]);
}
