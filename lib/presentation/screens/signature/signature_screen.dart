import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/app_controller.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});
  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _ctrl = Get.find<AppController>();
  final List<List<Offset?>> _strokes = [];
  List<Offset?> _currentStroke = [];
  bool _hasSigned = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isId = _ctrl.locale.languageCode == 'id';
    final profile = _ctrl.userProfile;
    final qrData = 'FoxApply\nNama: ${profile.fullName}\nEmail: ${profile.email}\nHP: ${profile.phone}\nGAP Studio';

    return Scaffold(
      appBar: AppBar(
        title: Text(isId ? 'TTD Electronic' : 'Electronic Signature'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(icon: const Icon(Icons.draw, size: 18),
                text: isId ? 'TTD Manual' : 'Draw Sign'),
            Tab(icon: const Icon(Icons.qr_code, size: 18),
                text: 'QR Code'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: TTD Manual
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  isId ? 'Tanda tangan di kotak bawah' : 'Sign in the box below',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: GestureDetector(
                        onPanStart: (d) => setState(() {
                          _currentStroke = [d.localPosition];
                          _hasSigned = true;
                        }),
                        onPanUpdate: (d) => setState(() => _currentStroke.add(d.localPosition)),
                        onPanEnd: (_) => setState(() {
                          _strokes.add(List.from(_currentStroke));
                          _currentStroke = [];
                        }),
                        child: CustomPaint(
                          painter: _SignPainter(strokes: _strokes, current: _currentStroke),
                          child: !_hasSigned
                              ? const Center(child: Text('✍️ Tanda tangan di sini...',
                                  style: TextStyle(color: AppColors.textSecondary)))
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: OutlinedButton.icon(
                      onPressed: () => setState(() { _strokes.clear(); _hasSigned = false; }),
                      icon: const Icon(Icons.clear),
                      label: Text(isId ? 'Hapus' : 'Clear'),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton.icon(
                      onPressed: _hasSigned ? () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(isId ? '✅ TTD disimpan!' : '✅ Signature saved!'),
                          backgroundColor: AppColors.success,
                        ));
                        Navigator.pop(context, true);
                      } : null,
                      icon: const Icon(Icons.save),
                      label: Text(isId ? 'Simpan' : 'Save'),
                    )),
                  ],
                ),
              ),
            ],
          ),

          // Tab 2: QR Code
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  isId
                      ? 'QR Code ini sebagai TTD digital kamu.\nOtomatis muncul di surat lamaran.'
                      : 'This QR Code is your digital signature.\nAuto appears in cover letter.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      QrImageView(data: qrData, version: QrVersions.auto, size: 200),
                      const SizedBox(height: 12),
                      Text(profile.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(profile.email,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      const Text('FoxApply - GAP Studio',
                          style: TextStyle(color: AppColors.primary, fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(isId
                            ? '✅ TTD QR aktif! Muncul di surat lamaran.'
                            : '✅ QR Signature active!'),
                        backgroundColor: AppColors.success,
                      ));
                      Navigator.pop(context, true);
                    },
                    icon: const Icon(Icons.qr_code),
                    label: Text(isId ? 'Gunakan TTD QR Ini' : 'Use This QR Signature'),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignPainter extends CustomPainter {
  final List<List<Offset?>> strokes;
  final List<Offset?> current;
  _SignPainter({required this.strokes, required this.current});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3A5F)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final stroke in [...strokes, current]) {
      for (int i = 0; i < stroke.length - 1; i++) {
        if (stroke[i] != null && stroke[i+1] != null) {
          canvas.drawLine(stroke[i]!, stroke[i+1]!, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_SignPainter old) => true;
}
