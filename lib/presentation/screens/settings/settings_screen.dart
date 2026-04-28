// lib/presentation/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../controllers/app_controller.dart';
import 'package:foxapply/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final ctrl = Get.find<AppController>();

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        children: [
          // Language Section
          _SectionHeader(title: l.language),
          Obx(() => _SettingsTile(
                icon: Icons.language,
                title: l.language,
                subtitle: ctrl.locale.languageCode == AppConstants.langId
                    ? l.indonesian
                    : l.english,
                onTap: () => _showLanguageDialog(context, ctrl, l),
              )),
          const Divider(),

          // About Section
          _SectionHeader(title: l.aboutApp),
          _SettingsTile(
            icon: Icons.info_outline,
            title: l.version,
            subtitle: AppConstants.appVersion,
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: l.privacyPolicy,
            onTap: () => _showPrivacyPolicy(context, l),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: l.termsOfService,
            onTap: () => _showTerms(context, l),
          ),
          const Divider(),

          // Danger Zone
          _SectionHeader(title: 'Data'),
          _SettingsTile(
            icon: Icons.delete_outline,
            title: 'Clear All Data',
            subtitle: 'Reset all saved data',
            iconColor: AppColors.error,
            onTap: () => _confirmClear(context, ctrl, l),
          ),

          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                const Text('🦊', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 4),
                Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'v${AppConstants.appVersion}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Made with ❤️ for job seekers',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showLanguageDialog(
      BuildContext context, AppController ctrl, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => RadioListTile<String>(
                  value: AppConstants.langEn,
                  groupValue: ctrl.locale.languageCode,
                  onChanged: (v) {
                    ctrl.setLanguage(v!);
                    Navigator.pop(context);
                  },
                  title: Text(l.english),
                  secondary: const Text('🇬🇧'),
                  activeColor: AppColors.primary,
                )),
            Obx(() => RadioListTile<String>(
                  value: AppConstants.langId,
                  groupValue: ctrl.locale.languageCode,
                  onChanged: (v) {
                    ctrl.setLanguage(v!);
                    Navigator.pop(context);
                  },
                  title: Text(l.indonesian),
                  secondary: const Text('🇮🇩'),
                  activeColor: AppColors.primary,
                )),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.privacyPolicy),
        content: const SingleChildScrollView(
          child: Text(
            'FoxApply Privacy Policy\n\n'
            'FoxApply collects the following data:\n'
            '• Personal information (name, email, phone) – stored locally on your device only\n'
            '• Photos and documents – stored locally on your device only\n\n'
            'We do NOT:\n'
            '• Upload your data to any server\n'
            '• Share your data with third parties\n'
            '• Use your data for advertising\n\n'
            'Camera and Storage permissions are used solely for document scanning and photo selection.\n\n'
            'All data stays on your device.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTerms(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.termsOfService),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of Service\n\n'
            'By using FoxApply, you agree to:\n\n'
            '1. Use the app for lawful purposes only\n'
            '2. Provide accurate information in your documents\n'
            '3. Take responsibility for the documents generated\n\n'
            'FoxApply is provided "as is" without warranty of any kind.\n'
            'The app is not responsible for the accuracy or outcome of job applications.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmClear(
      BuildContext context, AppController ctrl, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
            'This will delete all your saved profile data, education, experience, skills, and scanned documents. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () async {
              final storage = await _getStorage();
              await storage.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _getStorage() async {
    return await import_path_storage();
  }
}

// Dummy import - replace with actual storage call
Future import_path_storage() async {}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              fontSize: 12,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: AppColors.textSecondary)
          : null,
      onTap: onTap,
    );
  }
}
