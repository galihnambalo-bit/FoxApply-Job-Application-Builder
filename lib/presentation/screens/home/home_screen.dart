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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isId = Get.find<AppController>().locale.languageCode == 'id';
    final screens = [
      const _HomeTab(),
      const CVBuilderScreen(),
      const ScannerScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
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
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.badge_outlined),
                activeIcon: const Icon(Icons.badge),
                label: 'CV',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.document_scanner_outlined),
                activeIcon: const Icon(Icons.document_scanner),
                label: isId ? 'Dokumen' : 'Docs',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history_outlined),
                activeIcon: const Icon(Icons.history),
                label: isId ? 'Riwayat' : 'History',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                activeIcon: const Icon(Icons.settings),
                label: isId ? 'Pengaturan' : 'Settings',
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
              // Header
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('🦊', style: TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppConstants.appName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AppColors.primary)),
                      Text(isId ? 'Pembuat Paket Lamaran Kerja' : 'Job Application Builder',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: AppColors.primary),
                    onPressed: () => _showGuide(context, isId),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Banner
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isId ? 'Surat + CV + Dokumen → 1 PDF siap kirim' : 'Letter + CV + Docs → 1 PDF ready to send',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => ElevatedButton.icon(
                      onPressed: ctrl.canGenerate ? () => Get.toNamed('/generate') : null,
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

              Row(children: [
                const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(isId ? 'Ikuti langkah berikut:' : 'Follow these steps:',
                    style: Theme.of(context).textTheme.titleMedium),
              ]),
              const SizedBox(height: 12),

              // Step 1 - navigasi ke CV tab
              Obx(() => StepCard(
                step: 1,
                icon: Icons.person_outline,
                title: isId ? 'Isi Data Diri' : 'Fill Personal Data',
                subtitle: isId
                    ? 'Nama, email, HP, foto, pendidikan, pengalaman, skill'
                    : 'Name, email, phone, photo, education, experience, skills',
                isComplete: ctrl.userProfile.isComplete,
                onTap: () {
                  // Navigasi ke tab CV (index 1)
                  final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                  homeState?.setState(() => homeState._currentIndex = 1);
                },
              )),
              const SizedBox(height: 8),

              // Step 2 - navigasi ke cover letter
              Obx(() => StepCard(
                step: 2,
                icon: Icons.work_outline,
                title: isId ? 'Isi Info Lamaran' : 'Fill Job Info',
                subtitle: isId
                    ? 'Posisi yang dilamar & nama perusahaan'
                    : 'Position applied & company name',
                isComplete: ctrl.jobApplication.isComplete,
                onTap: () => Get.to(() => const CoverLetterScreen()),
              )),
              const SizedBox(height: 8),

              // Step 3 - navigasi ke tab Dokumen
              Obx(() => StepCard(
                step: 3,
                icon: Icons.folder_outlined,
                title: isId ? 'Upload/Scan Dokumen' : 'Upload/Scan Documents',
                subtitle: isId
                    ? 'Ijazah, KTP, sertifikat (PDF atau foto)\n${ctrl.scannedDocs.length} dokumen ditambahkan'
                    : 'Diploma, ID, certificate\n${ctrl.scannedDocs.length} documents added',
                isComplete: ctrl.scannedDocs.isNotEmpty,
                onTap: () {
                  final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                  homeState?.setState(() => homeState._currentIndex = 2);
                },
              )),
              const SizedBox(height: 8),

              Obx(() => StepCard(
                step: 4,
                icon: Icons.picture_as_pdf_outlined,
                title: isId ? 'Generate & Download' : 'Generate & Download',
                subtitle: isId
                    ? 'Klik tombol "Buat Sekarang" di atas'
                    : 'Click "Generate Now" button above',
                isComplete: false,
                onTap: ctrl.canGenerate ? () => Get.toNamed('/generate') : null,
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showGuide(BuildContext context, bool isId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(isId ? '🦊 Cara Pakai FoxApply' : '🦊 How to Use FoxApply',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _step('1', isId ? 'Isi Data Diri di tab CV' : 'Fill data in CV tab',
                isId ? 'Klik tab CV di bawah → isi nama, foto, pendidikan, pengalaman, skill' : 'Click CV tab → fill name, photo, education, experience, skills'),
            _step('2', isId ? 'Isi Info Lamaran' : 'Fill Job Info',
                isId ? 'Klik Step 2 → isi posisi & perusahaan' : 'Click Step 2 → fill position & company'),
            _step('3', isId ? 'Upload Dokumen' : 'Upload Documents',
                isId ? 'Klik tab Dokumen → upload PDF atau foto ijazah, KTP, dll' : 'Click Docs tab → upload PDF or photo'),
            _step('4', isId ? 'Generate Paket' : 'Generate Package',
                isId ? 'Klik "Buat Sekarang" → tonton iklan → download PDF' : 'Click "Generate Now" → watch ad → download PDF'),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(isId ? 'Mengerti!' : 'Got it!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _step(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30, height: 30,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: Center(child: Text(num,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          )),
        ],
      ),
    );
  }
}
