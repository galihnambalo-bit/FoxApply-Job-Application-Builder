// lib/presentation/controllers/app_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/storage_repository.dart';

class AppController extends GetxController {
  late StorageRepository _storage;

  final _locale = const Locale('en').obs;
  final _userProfile = UserProfile().obs;
  final _jobApplication = JobApplication().obs;
  final _scannedDocs = <ScannedDocument>[].obs;
  final _isGenerating = false.obs;
  final _selectedTemplate = AppConstants.templateModern.obs;

  Locale get locale => _locale.value;
  UserProfile get userProfile => _userProfile.value;
  JobApplication get jobApplication => _jobApplication.value;
  List<ScannedDocument> get scannedDocs => _scannedDocs;
  bool get isGenerating => _isGenerating.value;
  int get selectedTemplate => _selectedTemplate.value;

  @override
  void onInit() {
    super.onInit();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storage = await StorageRepository.getInstance();

    // Load language
    final lang = _storage.getLanguage();
    _locale.value = Locale(lang);

    // Load user profile
    final profile = _storage.getUserProfile();
    if (profile != null) _userProfile.value = profile;

    // Load scanned docs
    final docs = _storage.getScannedDocs();
    _scannedDocs.assignAll(docs);
  }

  Future<void> setLanguage(String langCode) async {
    _locale.value = Locale(langCode);
    await _storage.setLanguage(langCode);
    Get.updateLocale(Locale(langCode));
  }

  void updateUserProfile(UserProfile profile) {
    _userProfile.value = profile;
    _storage.saveUserProfile(profile);
  }

  void updateJobApplication(JobApplication job) {
    _jobApplication.value = job;
  }

  void addScannedDoc(ScannedDocument doc) {
    _scannedDocs.add(doc);
    _storage.saveScannedDocs(_scannedDocs);
  }

  void removeScannedDoc(String id) {
    _scannedDocs.removeWhere((d) => d.id == id);
    _storage.saveScannedDocs(_scannedDocs);
  }

  void reorderDocs(int oldIndex, int newIndex) {
    final doc = _scannedDocs.removeAt(oldIndex);
    _scannedDocs.insert(newIndex, doc);
    for (int i = 0; i < _scannedDocs.length; i++) {
      _scannedDocs[i].order = i;
    }
    _storage.saveScannedDocs(_scannedDocs);
  }

  void setTemplate(int template) => _selectedTemplate.value = template;

  void setGenerating(bool v) => _isGenerating.value = v;

  bool get canGenerate =>
      userProfile.isComplete &&
      jobApplication.isComplete &&
      scannedDocs.isNotEmpty &&
      userProfile.photoPath != null;
}
