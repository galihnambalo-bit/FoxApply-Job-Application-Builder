import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/storage_repository.dart';
import '../../data/models/user_profile.dart';

class AppController extends GetxController {
  late StorageRepository _storage;

  final _locale             = const Locale('en').obs;
  final _userProfile        = UserProfile().obs;
  final _jobApplication     = JobApplication().obs;
  final _scannedDocs        = <ScannedDocument>[].obs;
  final _isGenerating       = false.obs;
  final _selectedTemplate   = AppConstants.templateModern.obs;
  final _applicationHistory = <ApplicationHistory>[].obs;
  final _cvProfiles         = <CVProfile>[].obs;

  Locale                   get locale             => _locale.value;
  UserProfile              get userProfile        => _userProfile.value;
  JobApplication           get jobApplication     => _jobApplication.value;
  List<ScannedDocument>    get scannedDocs        => _scannedDocs;
  bool                     get isGenerating       => _isGenerating.value;
  int                      get selectedTemplate   => _selectedTemplate.value;
  List<ApplicationHistory> get applicationHistory => _applicationHistory;
  List<CVProfile>          get cvProfiles         => _cvProfiles;

  @override
  void onInit() {
    super.onInit();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storage = await StorageRepository.getInstance();
    _locale.value = Locale(_storage.getLanguage());
    final profile = _storage.getUserProfile();
    if (profile != null) _userProfile.value = profile;
    _scannedDocs.assignAll(_storage.getScannedDocs());
    _loadHistory();
    _loadCVProfiles();
  }

  // ── Language ──────────────────────────────────────────
  Future<void> setLanguage(String langCode) async {
    _locale.value = Locale(langCode);
    await _storage.setLanguage(langCode);
    Get.updateLocale(Locale(langCode));
  }

  // ── User Profile ──────────────────────────────────────
  void updateUserProfile(UserProfile profile) {
    _userProfile.value = profile;
    _storage.saveUserProfile(profile);
  }

  // ── Job Application ───────────────────────────────────
  void updateJobApplication(JobApplication job) {
    _jobApplication.value = job;
  }

  // ── Scanned Docs ──────────────────────────────────────
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

  void setTemplate(int t) => _selectedTemplate.value = t;
  void setGenerating(bool v) => _isGenerating.value = v;

  bool get canGenerate =>
      userProfile.isComplete &&
      jobApplication.isComplete &&
      scannedDocs.isNotEmpty &&
      userProfile.photoPath != null;

  // ── History ───────────────────────────────────────────
  void addToHistory(String pdfPath) {
    final h = ApplicationHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      companyName: jobApplication.targetCompany,
      position: jobApplication.targetPosition,
      date: DateTime.now().toString().split(' ')[0],
      pdfPath: pdfPath,
    );
    _applicationHistory.insert(0, h);
    _saveHistory();
  }

  void removeHistory(String id) {
    _applicationHistory.removeWhere((h) => h.id == id);
    _saveHistory();
  }

  void updateHistoryStatus(String id, String status) {
    final idx = _applicationHistory.indexWhere((h) => h.id == id);
    if (idx != -1) {
      _applicationHistory[idx].status = status;
      _applicationHistory.refresh();
      _saveHistory();
    }
  }

  void duplicateApplication(ApplicationHistory history) {
    updateJobApplication(JobApplication(
      targetPosition: history.position,
      targetCompany: '',
      customLetterContent: jobApplication.customLetterContent,
    ));
  }

  void _loadHistory() {
    try {
      final raw = _storage.getRaw('app_history');
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _applicationHistory.assignAll(
            list.map((e) => ApplicationHistory.fromJson(e)).toList());
      }
    } catch (_) {}
  }

  void _saveHistory() {
    _storage.setRaw('app_history',
        jsonEncode(_applicationHistory.map((e) => e.toJson()).toList()));
  }

  // ── Multi CV ──────────────────────────────────────────
  void saveCVProfile(String name) {
    final cvp = CVProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      profile: userProfile,
      template: selectedTemplate,
    );
    final idx = _cvProfiles.indexWhere((p) => p.name == name);
    if (idx != -1) {
      _cvProfiles[idx] = cvp;
    } else {
      _cvProfiles.add(cvp);
    }
    _saveCVProfiles();
  }

  void loadCVProfile(CVProfile profile) {
    _userProfile.value = profile.profile;
    _selectedTemplate.value = profile.template;
    _storage.saveUserProfile(profile.profile);
  }

  void deleteCVProfile(String id) {
    _cvProfiles.removeWhere((p) => p.id == id);
    _saveCVProfiles();
  }

  void _loadCVProfiles() {
    try {
      final raw = _storage.getRaw('cv_profiles');
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _cvProfiles.assignAll(
            list.map((e) => CVProfile.fromJson(e)).toList());
      }
    } catch (_) {}
  }

  void _saveCVProfiles() {
    _storage.setRaw('cv_profiles',
        jsonEncode(_cvProfiles.map((e) => e.toJson()).toList()));
  }
}
