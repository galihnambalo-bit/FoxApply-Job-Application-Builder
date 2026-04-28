// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../controllers/app_controller.dart';
import '../cv_builder/cv_builder_screen.dart';
import '../cover_letter/cover_letter_screen.dart';
import '../scanner/scanner_screen.dart';
import '../settings/settings_screen.dart';
import '../../widgets/step_card.dart';
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
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.badge_outlined),
            activeIcon: const Icon(Icons.badge),
            label: l.cvBuilder,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.document_scanner_outlined),
            activeIcon: const Icon(Icons.document_scanner),
            label: l.scanner,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: l.settings,
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('🦊',
                          style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppConstants.appName,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppColors.primary)),
                      Text('Job Application Builder',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

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
                      l.createPackage,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '1 PDF • CV + ${l.coverLetter} + Docs',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => ElevatedButton.icon(
                          onPressed: ctrl.canGenerate
                              ? () => _generatePackage(context)
                              : null,
                          icon: const Text('🦊', style: TextStyle(fontSize: 16)),
                          label: Text(l.generateNow),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: Colors.white30,
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Steps
              Text(l.step.replaceAll('{current}', '').replaceAll('{total}', ''),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),

              StepCard(
                step: 1,
                icon: Icons.person_outline,
                title: l.personalData,
                subtitle: l.fullName,
                isComplete: ctrl.userProfile.isComplete,
                onTap: () => Get.to(() => const ProfileInputScreen()),
              ),
              const SizedBox(height: 10),
              StepCard(
                step: 2,
                icon: Icons.work_outline,
                title: l.jobSection,
                subtitle: '${l.targetPosition} & ${l.targetCompany}',
                isComplete: ctrl.jobApplication.isComplete,
                onTap: () => Get.to(() => const CoverLetterScreen()),
              ),
              const SizedBox(height: 10),
              Obx(() => StepCard(
                    step: 3,
                    icon: Icons.document_scanner_outlined,
                    title: l.docsSection,
                    subtitle: '${ctrl.scannedDocs.length} ${l.scannedDocs}',
                    isComplete: ctrl.scannedDocs.isNotEmpty,
                    onTap: () {},
                  )),
              const SizedBox(height: 10),
              StepCard(
                step: 4,
                icon: Icons.picture_as_pdf_outlined,
                title: l.outputSection,
                subtitle: l.packageReady,
                isComplete: false,
                onTap: ctrl.canGenerate
                    ? () => _generatePackage(context)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generatePackage(BuildContext context) async {
    // Navigate to generation screen
    Get.toNamed('/generate');
  }
}

// Simple profile input screen placeholder
class ProfileInputScreen extends StatelessWidget {
  const ProfileInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.personalData)),
      body: const Center(child: Text('Profile Input - See full implementation')),
    );
  }
}
