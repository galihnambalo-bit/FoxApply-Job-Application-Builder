// lib/presentation/screens/cv_builder/cv_builder_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_profile.dart';
import '../../controllers/app_controller.dart';
import 'package:uuid/uuid.dart';
import 'package:foxapply/l10n/app_localizations.dart';

class CVBuilderScreen extends StatefulWidget {
  const CVBuilderScreen({super.key});

  @override
  State<CVBuilderScreen> createState() => _CVBuilderScreenState();
}

class _CVBuilderScreenState extends State<CVBuilderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _ctrl = Get.find<AppController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.cvBuilder),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(icon: Icon(Icons.person_outline, size: 18), text: l.personalData),
            Tab(icon: Icon(Icons.school_outlined, size: 18), text: l.education),
            Tab(icon: Icon(Icons.work_outline, size: 18), text: l.experience),
            Tab(icon: Icon(Icons.star_outline, size: 18), text: l.skills),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PersonalDataTab(ctrl: _ctrl),
          _EducationTab(ctrl: _ctrl),
          _ExperienceTab(ctrl: _ctrl),
          _SkillsTab(ctrl: _ctrl),
        ],
      ),
    );
  }
}

// Personal Data Tab
class _PersonalDataTab extends StatefulWidget {
  final AppController ctrl;
  const _PersonalDataTab({required this.ctrl});

  @override
  State<_PersonalDataTab> createState() => _PersonalDataTabState();
}

class _PersonalDataTabState extends State<_PersonalDataTab> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final p = widget.ctrl.userProfile;
    _nameCtrl = TextEditingController(text: p.fullName);
    _emailCtrl = TextEditingController(text: p.email);
    _phoneCtrl = TextEditingController(text: p.phone);
    _addressCtrl = TextEditingController(text: p.address);
    _cityCtrl = TextEditingController(text: p.city);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final profile = widget.ctrl.userProfile;
    profile.fullName = _nameCtrl.text;
    profile.email = _emailCtrl.text;
    profile.phone = _phoneCtrl.text;
    profile.address = _addressCtrl.text;
    profile.city = _cityCtrl.text;
    widget.ctrl.updateUserProfile(profile);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.successSaved)),
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file != null) {
      final profile = widget.ctrl.userProfile;
      profile.photoPath = file.path;
      widget.ctrl.updateUserProfile(profile);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo upload
            Center(
              child: Column(
                children: [
                  Obx(() {
                    final photoPath = widget.ctrl.userProfile.photoPath;
                    return Container(
                      width: 100,
                      height: 133,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider, width: 2),
                        color: AppColors.background,
                      ),
                      child: photoPath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(photoPath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.person, size: 50)),
                            )
                          : const Icon(Icons.person, size: 50,
                              color: AppColors.textSecondary),
                    );
                  }),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _pickPhoto(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, size: 16),
                        label: Text(l.takePhoto),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _pickPhoto(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library, size: 16),
                        label: Text(l.chooseGallery),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildField(l.fullName, _nameCtrl,
                validator: (v) => v!.isEmpty ? l.errorRequired : null),
            _buildField(l.email, _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => !v!.contains('@') ? l.errorEmail : null),
            _buildField(l.phone, _phoneCtrl,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? l.errorRequired : null),
            _buildField(l.address, _addressCtrl, maxLines: 2),
            _buildField(l.city, _cityCtrl),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(l.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: validator,
      ),
    );
  }
}

// Education Tab
class _EducationTab extends StatelessWidget {
  final AppController ctrl;
  const _EducationTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.userProfile.education.length,
            itemBuilder: (_, i) {
              final edu = ctrl.userProfile.education[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(edu.institution),
                  subtitle: Text('${edu.degree} - ${edu.major}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () {
                      final profile = ctrl.userProfile;
                      profile.education.removeAt(i);
                      ctrl.updateUserProfile(profile);
                    },
                  ),
                ),
              );
            },
          )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEducation(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l.addEducation,
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddEducation(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final institution = TextEditingController();
    final degree = TextEditingController();
    final major = TextEditingController();
    final year = TextEditingController();
    final gpa = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.addEducation,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(controller: institution,
                decoration: InputDecoration(labelText: l.institution)),
            const SizedBox(height: 10),
            TextField(controller: degree,
                decoration: InputDecoration(labelText: l.degree)),
            const SizedBox(height: 10),
            TextField(controller: major,
                decoration: InputDecoration(labelText: l.major)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextField(controller: year,
                  decoration: InputDecoration(labelText: l.graduationYear))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: gpa,
                  decoration: InputDecoration(labelText: l.gpa))),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final profile = ctrl.userProfile;
                  profile.education.add(Education(
                    id: const Uuid().v4(),
                    institution: institution.text,
                    degree: degree.text,
                    major: major.text,
                    graduationYear: year.text,
                    gpa: gpa.text,
                  ));
                  ctrl.updateUserProfile(profile);
                  Navigator.pop(context);
                },
                child: Text(l.add),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Experience Tab - similar structure
class _ExperienceTab extends StatelessWidget {
  final AppController ctrl;
  const _ExperienceTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.userProfile.experience.length,
            itemBuilder: (_, i) {
              final exp = ctrl.userProfile.experience[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(exp.position),
                  subtitle: Text('${exp.company} • ${exp.startDate}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () {
                      final profile = ctrl.userProfile;
                      profile.experience.removeAt(i);
                      ctrl.updateUserProfile(profile);
                    },
                  ),
                ),
              );
            },
          )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExperience(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l.addExperience,
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddExperience(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final company = TextEditingController();
    final position = TextEditingController();
    final start = TextEditingController();
    final end = TextEditingController();
    final desc = TextEditingController();
    bool current = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: company,
                  decoration: InputDecoration(labelText: l.company)),
              const SizedBox(height: 10),
              TextField(controller: position,
                  decoration: InputDecoration(labelText: l.position)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextField(controller: start,
                    decoration: InputDecoration(labelText: l.startDate))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: end,
                    enabled: !current,
                    decoration: InputDecoration(labelText: l.endDate))),
              ]),
              CheckboxListTile(
                value: current,
                onChanged: (v) => setS(() => current = v!),
                title: Text(l.currentlyWorking),
                contentPadding: EdgeInsets.zero,
              ),
              TextField(controller: desc,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: l.jobDescription)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final profile = ctrl.userProfile;
                    profile.experience.add(Experience(
                      id: const Uuid().v4(),
                      company: company.text,
                      position: position.text,
                      startDate: start.text,
                      endDate: end.text,
                      currentlyWorking: current,
                      description: desc.text,
                    ));
                    ctrl.updateUserProfile(profile);
                    Navigator.pop(context);
                  },
                  child: Text(l.add),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// Skills Tab
class _SkillsTab extends StatelessWidget {
  final AppController ctrl;
  const _SkillsTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.userProfile.skills.length,
            itemBuilder: (_, i) {
              final skill = ctrl.userProfile.skills[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(skill.name),
                  subtitle: Text(_levelLabel(skill.level, l)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () {
                      final p = ctrl.userProfile;
                      p.skills.removeAt(i);
                      ctrl.updateUserProfile(p);
                    },
                  ),
                ),
              );
            },
          )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSkill(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l.addSkill,
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  String _levelLabel(SkillLevel level, AppLocalizations l) {
    switch (level) {
      case SkillLevel.beginner: return l.beginner;
      case SkillLevel.intermediate: return l.intermediate;
      case SkillLevel.advanced: return l.advanced;
      case SkillLevel.expert: return l.expert;
    }
  }

  void _showAddSkill(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final name = TextEditingController();
    SkillLevel level = SkillLevel.intermediate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name,
                  decoration: InputDecoration(labelText: l.skillName)),
              const SizedBox(height: 16),
              Text(l.skillLevel),
              ...SkillLevel.values.map((lv) => RadioListTile<SkillLevel>(
                value: lv,
                groupValue: level,
                onChanged: (v) => setS(() => level = v!),
                title: Text(_levelLabel(lv, l)),
                activeColor: AppColors.primary,
              )),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final p = ctrl.userProfile;
                    p.skills.add(Skill(
                        id: const Uuid().v4(),
                        name: name.text,
                        level: level));
                    ctrl.updateUserProfile(p);
                    Navigator.pop(context);
                  },
                  child: Text(l.add),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
