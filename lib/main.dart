// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'presentation/controllers/app_controller.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/pdf_preview/pdf_preview_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetX controller
  Get.put(AppController());

  runApp(const FoxApplyApp());
}

class FoxApplyApp extends StatelessWidget {
  const FoxApplyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();

    return Obx(() => GetMaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,

          // Localization
          locale: ctrl.locale,
          fallbackLocale: const Locale(AppConstants.langEn),
          supportedLocales: const [
            Locale('en'),
            Locale('id'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // Routes
          initialRoute: '/',
          getPages: [
            GetPage(
              name: '/',
              page: () => const HomeScreen(),
            ),
            GetPage(
              name: '/generate',
              page: () => const GeneratePackageScreen(),
            ),
          ],
        ));
  }
}
