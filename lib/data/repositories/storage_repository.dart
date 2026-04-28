// lib/data/repositories/storage_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../../core/constants/app_constants.dart';

class StorageRepository {
  static StorageRepository? _instance;
  late SharedPreferences _prefs;

  StorageRepository._();

  static Future<StorageRepository> getInstance() async {
    _instance ??= StorageRepository._();
    _instance!._prefs = await SharedPreferences.getInstance();
    return _instance!;
  }

  // Language
  String getLanguage() => _prefs.getString(AppConstants.keyLanguage) ?? AppConstants.langEn;
  Future<void> setLanguage(String lang) => _prefs.setString(AppConstants.keyLanguage, lang);

  // User Profile
  UserProfile? getUserProfile() {
    final s = _prefs.getString(AppConstants.keyUserData);
    if (s == null) return null;
    try { return UserProfile.fromJsonString(s); } catch (_) { return null; }
  }

  Future<void> saveUserProfile(UserProfile profile) =>
      _prefs.setString(AppConstants.keyUserData, profile.toJsonString());

  // Scanned Documents
  List<ScannedDocument> getScannedDocs() {
    final s = _prefs.getString(AppConstants.keyScannedDocs);
    if (s == null) return [];
    try {
      final list = jsonDecode(s) as List;
      return list.map((e) => ScannedDocument.fromJson(e)).toList();
    } catch (_) { return []; }
  }

  Future<void> saveScannedDocs(List<ScannedDocument> docs) =>
      _prefs.setString(AppConstants.keyScannedDocs,
          jsonEncode(docs.map((e) => e.toJson()).toList()));

  Future<void> clearAll() => _prefs.clear();
}
