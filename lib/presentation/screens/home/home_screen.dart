import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../controllers/app_controller.dart';
import '../cv_builder/cv_builder_screen.dart';
import '../cover_letter/cover_letter_screen.dart';
import '../scanner/scanner_screen.dart';
import '../settings/settings_screen.dart';
import '../home/history_screen.dart';
import '../../widgets/step_card.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/fox_button.dart';
import 'package:foxapply/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    _HomeTab(),
    CVBuilderScreen(),
    ScannerScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isId = Get.find<AppController>().locale.languageCode == 'id';

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: isId ? 'Beranda' : 'Home',
                tooltip: isId ? 'Halaman utama' : 'Main page',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.badge_outlined),
                activeIcon: const Icon(Icons.badge),
                label: isId ? 'CV' : 'CV',
                tooltip: isId ? 'Buat & edit CV kamu' : 'Create & edit your CV',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.document_scanner_outlined),
                activeIcon: const Icon(Icons.document_scanner),
                label: isId ? 'Dokumen' : 'Docs',
                tooltip: isId ? 'Scan atau upload dokumen' : 'Scan or upload documents',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history_outlined),
                activeIcon: const Icon(Icons.history),
                label: isId ? 'Riwayat' : 'History',
                tooltip: isId ? 'Riwayat lamaran kerja' : 'Application history',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                activeIcon: const Icon(Icons.settings),
                label: isId ? 'Pengaturan' : 'Settings',
                tooltip: isId ? 'Pengaturan aplikasi' : 'App settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final ctrl = Get.find<AppController>();
    final isId = ctrl.locale.languageCode == 'id';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header ──────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                        child: Text('🦊', style: TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppConstants.appName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AppColors.primary)),
                      Text(isId
                          ? 'Pembuat Paket Lamaran Kerja'
                          : 'Job Application Builder',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const Spacer(),
                  // Tombol bantuan
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: AppColors.primary),
                    tooltip: isId ? 'Cara penggunaan' : 'How to use',
                    onPressed: () => _showGuide(context, isId),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Banner Generate ──────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, Color(0xFF2D5080)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isId ? '🦊 Buat Paket Lamaran' : '🦊 Create Application Package',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isId
                          ? 'Surat + CV + Dokumen → 1 PDF siap kirim'
                          : 'Letter + CV + Docs → 1 PDF ready to send',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => ElevatedButton.icon(
                      onPressed: ctrl.canGenerate
                          ? () => Get.toNamed('/generate')
                          : null,
                      icon: const Icon(Icons.rocket_launch, size: 18),
                      label: Text(isId ? 'Buat Sekarang' : 'Generate Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: Colors.white24,
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Panduan Langkah ──────────────────────────
              Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    isId ? 'Ikuti langkah berikut:' : 'Follow these steps:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Step 1 - Data Diri
              StepCard(
                step: 1,
                icon: Icons.person_outline,
                title: isId ? 'Isi Data Diri' : 'Fill Personal Data',
                subtitle: isId
                    ? 'Nama, email, HP, foto, pendidikan, pengalaman, skill'
                    : 'Name, email, phone, photo, education, experience, skills',
                isComplete: ctrl.userProfile.isComplete,
                onTap: () {},
              ),
              const SizedBox(height: 8),

              // Step 2 - Info Lamaran
              StepCard(
                step: 2,
                icon: Icons.work_outline,
                title: isId ? 'Isi Info Lamaran' : 'Fill Job Info',
                subtitle: isId
                    ? 'Posisi yang dilamar & nama perusahaan'
                    : 'Position applied & company name',
                isComplete: ctrl.jobApplication.isComplete,
                onTap: () => Get.to(() => const CoverLetterScreen()),
              ),
              const SizedBox(height: 8),

              // Step 3 - Dokumen
              Obx(() => StepCard(
                step: 3,
                icon: Icons.folder_outlined,
                title: isId ? 'Upload/Scan Dokumen' : 'Upload/Scan Documents',
                subtitle: isId
                    ? 'Ijazah, KTP, sertifikat (PDF atau foto)\n${ctrl.scannedDocs.length} dokumen ditambahkan'
                    : 'Diploma, ID, certificate (PDF or photo)\n${ctrl.scannedDocs.length} documents added',
                isComplete: ctrl.scannedDocs.isNotEmpty,
                onTap: () {},
              )),
              const SizedBox(height: 8),

              // Step 4 - Generate
              StepCard(
                step: 4,
                icon: Icons.picture_as_pdf_outlined,
                title: isId ? 'Generate & Download' : 'Generate & Download',
                subtitle: isId
                    ? 'Klik tombol "Buat Sekarang" di atas\nPDF siap kirim via WhatsApp/Email'
                    : 'Click "Generate Now" button above\nPDF ready to send via WhatsApp/Email',
                isComplete: false,
                onTap: ctrl.canGenerate
                    ? () => Get.toNamed('/generate')
                    : null,
              ),
              const SizedBox(height: 24),

              // ── Fitur Lainnya ────────────────────────────
              Text(
                isId ? 'Fitur Lainnya:' : 'Other Features:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.compress,
                      color: AppColors.accent,
                      title: isId ? 'Compress PDF' : 'Compress PDF',
                      subtitle: isId ? 'Perkecil ukuran PDF' : 'Reduce PDF size',
                      onTap: () => Get.toNamed('/compress'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.history,
                      color: AppColors.secondary,
                      title: isId ? 'Riwayat' : 'History',
                      subtitle: isId ? 'Lihat lamaran lalu' : 'View past applications',
                      onTap: () => Get.to(() => const HistoryScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.copy_all,
                      color: AppColors.primary,
                      title: isId ? 'Duplikat' : 'Duplicate',
                      subtitle: isId ? 'Salin lamaran lama' : 'Copy old application',
                      onTap: () => Get.to(() => const HistoryScreen()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.upload_file,
                      color: AppColors.success,
                      title: isId ? 'Upload PDF' : 'Upload PDF',
                      subtitle: isId ? 'Upload langsung dari HP' : 'Upload directly from phone',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Panduan penggunaan ──────────────────────────────────
  void _showGuide(BuildContext context, bool isId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('🦊', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Text(
                    isId ? 'Cara Pakai FoxApply' : 'How to Use FoxApply',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _GuideStep(
                number: '1',
                icon: Icons.person,
                color: AppColors.primary,
                title: isId ? 'Isi Data Diri' : 'Fill Personal Data',
                desc: isId
                    ? 'Buka menu CV → isi nama, email, HP, upload foto 3x4, tambah pendidikan, pengalaman kerja, dan skill.'
                    : 'Open CV menu → fill name, email, phone, upload 3x4 photo, add education, work experience, and skills.',
              ),
              _GuideStep(
                number: '2',
                icon: Icons.work,
                color: AppColors.accent,
                title: isId ? 'Isi Info Lamaran' : 'Fill Job Info',
                desc: isId
                    ? 'Klik step 2 di beranda → isi posisi yang kamu lamar dan nama perusahaan. Surat lamaran akan dibuat otomatis!'
                    : 'Click step 2 on home → fill the position you apply for and company name. Cover letter will be generated automatically!',
              ),
              _GuideStep(
                number: '3',
                icon: Icons.folder,
                color: AppColors.secondary,
                title: isId ? 'Upload/Scan Dokumen' : 'Upload/Scan Documents',
                desc: isId
                    ? 'Buka menu Dokumen → pilih:\n• Upload PDF (ijazah, transkrip, sertifikat)\n• Upload foto dari galeri\n• Scan langsung dengan kamera\n\nBisa hapus halaman yang tidak diperlukan!'
                    : 'Open Docs menu → choose:\n• Upload PDF (diploma, transcript, certificate)\n• Upload photo from gallery\n• Scan directly with camera\n\nCan delete unnecessary pages!',
              ),
              _GuideStep(
                number: '4',
                icon: Icons.rocket_launch,
                color: AppColors.primary,
                title: isId ? 'Generate Paket' : 'Generate Package',
                desc: isId
                    ? 'Klik tombol "Buat Sekarang" → tunggu proses → tonton iklan singkat → PDF siap didownload dan dibagikan!'
                    : 'Click "Generate Now" → wait for process → watch short ad → PDF ready to download and share!',
              ),
              _GuideStep(
                number: '5',
                icon: Icons.compress,
                color: AppColors.accent,
                title: isId ? 'Compress PDF (Opsional)' : 'Compress PDF (Optional)',
                desc: isId
                    ? 'Kalau PDF terlalu besar (misal syarat max 2MB), gunakan fitur Compress PDF di beranda. Bisa pilih target ukuran 1MB, 2MB, 3MB, atau 5MB.'
                    : 'If PDF is too large (e.g. max 2MB requirement), use Compress PDF feature on home. Can choose target size 1MB, 2MB, 3MB, or 5MB.',
              ),
              _GuideStep(
                number: '6',
                icon: Icons.copy_all,
                color: AppColors.success,
                title: isId ? 'Lamar Perusahaan Lain' : 'Apply to Another Company',
                desc: isId
                    ? 'Buka menu Riwayat → klik "Duplikat" pada lamaran sebelumnya → tinggal ganti nama perusahaan → generate ulang. Cepat!'
                    : 'Open History menu → click "Duplicate" on previous application → just change company name → regenerate. Fast!',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isId
                            ? 'Tips: Simpan beberapa versi CV untuk posisi berbeda (CV Admin, CV Sales, CV Bahasa Inggris) di menu CV!'
                            : 'Tip: Save multiple CV versions for different positions (Admin CV, Sales CV, English CV) in the CV menu!',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isId ? 'Mengerti, Mulai!' : 'Got it, Start!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Feature Card ────────────────────────────────────────────
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(14),
          color: color.withValues(alpha: 0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color, fontSize: 13)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── Guide Step ──────────────────────────────────────────────
class _GuideStep extends StatelessWidget {
  final String number;
  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  const _GuideStep({
    required this.number,
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder screen
class ProfileInputScreen extends StatelessWidget {
  const ProfileInputScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Input')),
    );
  }
}
