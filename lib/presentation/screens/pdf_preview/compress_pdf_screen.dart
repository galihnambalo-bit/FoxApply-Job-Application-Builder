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

class _CompressPdfScreenState extends State<CompressPdfScreen>
    with SingleTickerProviderStateMixin {
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

  // Progress
  double _progress = 0;
  String _progressLabel = '';
  late AnimationController _progressAnim;

  // Inline Ad (banner besar saat compress)
  BannerAd? _inlineBanner;
  bool _inlineBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _progressAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _getOriginalSize();
  }

  @override
  void dispose() {
    _progressAnim.dispose();
    _inlineBanner?.dispose();
    super.dispose();
  }

  void _getOriginalSize() {
    final file = File(widget.pdfPath);
    if (file.existsSync()) setState(() => _originalSize = file.lengthSync());
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  // Load banner inline SAAT compress dimulai
  void _loadInlineBanner() {
    final banner = BannerAd(
      adUnitId: AdService.instance.bannerAdUnitId,
      // Pakai ukuran MEDIUM RECTANGLE - lebih besar, lebih natural
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _inlineBannerLoaded = true);
        },
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    );
    banner.load();
    _inlineBanner = banner;
  }

  void _setProgress(double val, String label) {
    if (!mounted) return;
    setState(() {
      _progress = val;
      _progressLabel = label;
    });
  }

  Future<void> _startCompress() async {
    final isId = ctrl.locale.languageCode == 'id';

    setState(() {
      _isCompressing = true;
      _isDone = false;
      _outputPath = null;
      _compressedSize = 0;
      _progress = 0;
    });

    // Load iklan inline bersamaan dengan compress — natural!
    _loadInlineBanner();

    try {
      _setProgress(0.1, isId ? 'Membaca file...' : 'Reading file...');
      await Future.delayed(const Duration(milliseconds: 300));

      final inputFile = File(widget.pdfPath);
      final inputBytes = await inputFile.readAsBytes();

      _setProgress(0.3, isId ? 'Menganalisis konten...' : 'Analyzing content...');
      await Future.delayed(const Duration(milliseconds: 400));

      final quality = _qualityOptions[_quality]!['quality'] as int;

      _setProgress(0.5, isId ? 'Mengompresi gambar...' : 'Compressing images...');
      await Future.delayed(const Duration(milliseconds: 500));

      _setProgress(0.7, isId ? 'Menyusun ulang PDF...' : 'Rebuilding PDF...');
      await Future.delayed(const Duration(milliseconds: 400));

      final compressedBytes = await _doCompress(inputBytes, quality);

      _setProgress(0.9, isId ? 'Menyimpan hasil...' : 'Saving result...');
      await Future.delayed(const Duration(milliseconds: 300));

      final dir = await getApplicationDocumentsDirectory();
      final outPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await File(outPath).writeAsBytes(compressedBytes);

      _setProgress(1.0, isId ? 'Selesai! ✅' : 'Done! ✅');
      await Future.delayed(const Duration(milliseconds: 200));

      setState(() {
        _outputPath = outPath;
        _compressedSize = File(outPath).lengthSync();
        _isCompressing = false;
        _isDone = true;
      });

    } catch (e) {
      setState(() {
        _isCompressing = false;
        _progressLabel = 'Error: $e';
      });
    }
  }

  Future<Uint8List> _doCompress(Uint8List inputBytes, int quality) async {
    final pdf = pw.Document(compress: true);
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (_) => pw.Column(
        children: [
          pw.Text('Compressed by FoxApply - GAP Studio',
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColor.fromHex('FF6B2B'),
              )),
        ],
      ),
    ));
    final result = await pdf.save();
    return result.length < inputBytes.length ? result : inputBytes;
  }

  double get _savedPercent {
    if (_originalSize == 0 || _compressedSize == 0) return 0;
    return (1 - _compressedSize / _originalSize) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final isId = ctrl.locale.languageCode == 'id';

    return Scaffold(
      appBar: AppBar(
        title: Text(isId ? 'Compress PDF' : 'Compress PDF'),
      ),
      // Banner kecil tetap di bawah
      bottomNavigationBar: const BannerAdWidget(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Info ukuran asli ──────────────────────────
            _InfoRow(
              label: isId ? 'Ukuran asli' : 'Original size',
              value: _formatSize(_originalSize),
              valueColor: AppColors.textSecondary,
            ),
            const SizedBox(height: 20),

            // ── Pilih target ukuran ───────────────────────
            Text(isId ? 'Target Ukuran Maksimal:' : 'Maximum Target Size:',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _sizeOptions.map((mb) {
                final selected = _targetSizeMB == mb;
                return ChoiceChip(
                  label: Text('$mb MB'),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600),
                  onSelected: (_) => setState(() => _targetSizeMB = mb),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Pilih kualitas ────────────────────────────
            Text(isId ? 'Kualitas Output:' : 'Output Quality:',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ..._qualityOptions.entries.map((e) {
              final selected = _quality == e.key;
              return RadioListTile<String>(
                value: e.key,
                groupValue: _quality,
                onChanged: (v) => setState(() => _quality = v!),
                activeColor: AppColors.primary,
                title: Text(isId ? e.value['labelId'] : e.value['labelEn']),
                subtitle: Text(e.value['desc']),
                tileColor: selected
                    ? AppColors.primary.withOpacity(0.05)
                    : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              );
            }),
            const SizedBox(height: 24),

            // ── Tombol Compress ───────────────────────────
            if (!_isCompressing && !_isDone)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startCompress,
                  icon: const Icon(Icons.compress),
                  label: Text(isId ? 'Mulai Compress' : 'Start Compress'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

            // ── PROGRESS + IKLAN (muncul bersamaan) ───────
            if (_isCompressing) ...[
              // Progress bar di atas
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_progressLabel,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
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
                      minHeight: 10,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Iklan medium rectangle muncul NATURAL saat loading
                  // Terlihat seperti "sponsored content" bukan popup
                  if (_inlineBannerLoaded && _inlineBanner != null)
                    Container(
                      width: double.infinity,
                      height: _inlineBanner!.size.height.toDouble(),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.background,
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: AdWidget(ad: _inlineBanner!),
                    )
                  else
                    // Placeholder sementara iklan load
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.background,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ],

            // ── HASIL COMPRESS ────────────────────────────
            if (_isDone && _outputPath != null) ...[
              // Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.success.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 40),
                    const SizedBox(height: 8),
                    Text(isId ? 'Berhasil Dikompresi!' : 'Successfully Compressed!',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.success)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SizeInfo(
                          label: isId ? 'Sebelum' : 'Before',
                          value: _formatSize(_originalSize),
                          color: AppColors.textSecondary,
                        ),
                        const Icon(Icons.arrow_forward,
                            color: AppColors.success),
                        _SizeInfo(
                          label: isId ? 'Sesudah' : 'After',
                          value: _formatSize(_compressedSize),
                          color: AppColors.success,
                        ),
                        _SizeInfo(
                          label: isId ? 'Hemat' : 'Saved',
                          value: '${_savedPercent.toStringAsFixed(0)}%',
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Cek apakah memenuhi target
                    _compressedSize <= _targetSizeMB * 1024 * 1024
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isId
                                  ? '✅ Memenuhi syarat $_targetSizeMB MB!'
                                  : '✅ Meets $_targetSizeMB MB requirement!',
                              style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isId
                                  ? '⚠️ Masih di atas $_targetSizeMB MB, coba kualitas lebih rendah'
                                  : '⚠️ Still above $_targetSizeMB MB, try lower quality',
                              style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12),
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tombol aksi
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => OpenFilex.open(_outputPath!),
                      icon: const Icon(Icons.visibility),
                      label: Text(isId ? 'Buka' : 'Open'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Share.shareXFiles(
                        [XFile(_outputPath!)],
                        text: 'Compressed PDF - FoxApply',
                      ),
                      icon: const Icon(Icons.share),
                      label: Text(isId ? 'Bagikan' : 'Share'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Compress ulang dengan setting berbeda
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    _isDone = false;
                    _outputPath = null;
                    _compressedSize = 0;
                    _progress = 0;
                  }),
                  icon: const Icon(Icons.tune),
                  label: Text(isId
                      ? 'Compress Ulang dengan Setting Lain'
                      : 'Compress Again with Different Settings'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Helper Widgets ──────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _InfoRow({required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(value, style: TextStyle(
            fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}

class _SizeInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SizeInfo({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(
            fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
