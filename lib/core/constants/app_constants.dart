// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  static const String appName = 'FoxApply';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.foxapply.app';

  // Storage Keys
  static const String keyLanguage = 'app_language';
  static const String keyUserData = 'user_data';
  static const String keyEducation = 'education_list';
  static const String keyExperience = 'experience_list';
  static const String keySkills = 'skills_list';
  static const String keyScannedDocs = 'scanned_docs';

  // Supported Languages
  static const String langEn = 'en';
  static const String langId = 'id';

  // PDF settings
  static const double pageWidth = 595.28;   // A4 width in points
  static const double pageHeight = 841.89;  // A4 height in points
  static const double marginH = 40.0;
  static const double marginV = 40.0;

  // Photo aspect ratio (3:4)
  static const double photoAspectRatio = 3 / 4;

  // CV Templates
  static const int templateModern = 1;
  static const int templateProfessional = 2;
  static const int templateCreative = 3;
}
