import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_profile.dart';
import '../../controllers/app_controller.dart';

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
    final isId = _ctrl.locale.languageCode == 'id';
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(isId ? 'Pembuat CV' : 'CV Builder'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(icon: const Icon(Icons.person_outline, size: 18),
                text: isId ? 'Data Diri' : 'Personal Data'),
            Tab(icon: const Icon(Icons.school_outlined, size: 18),
                text: isId ? 'Pendidikan' : 'Education'),
            Tab(icon: const Icon(Icons.work_outline, size: 18),
                text: isId ? 'Pengalaman' : 'Experience'),
            Tab(icon: const Icon(Icons.star_outline, size: 18),
                text: isId ? 'Keahlian' : 'Skills'),
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
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.ctrl.userProfile;
    _nameCtrl   = TextEditingController(text: p.fullName);
    _emailCtrl  = TextEditingController(text: p.email);
    _phoneCtrl  = TextEditingController(text: p.phone);
    _addressCtrl= TextEditingController(text: p.address);
    _cityCtrl   = TextEditingController(text: p.city);
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose();
    _addressCtrl.dispose(); _cityCtrl.dispose();
    super.dispose();
  }

  // AUTO SAVE saat field berubah
  void _autoSave() {
    final profile = widget.ctrl.userProfile;
    profile.fullName = _nameCtrl.text;
    profile.email    = _emailCtrl.text;
    profile.phone    = _phoneCtrl.text;
    profile.address  = _addressCtrl.text;
    profile.city     = _cityCtrl.text;
    widget.ctrl.updateUserProfile(profile);
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final file = await ImagePicker().pickImage(
        source: source, imageQuality: 85, maxWidth: 800);
    if (file == null) return;
    final profile = widget.ctrl.userProfile;
    profile.photoPath = file.path;
    widget.ctrl.updateUserProfile(profile);
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Foto berhasil diupload!'),
            backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isId = widget.ctrl.locale.languageCode == 'id';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO - tampil langsung setelah upload
            Center(
              child: Column(
                children: [
                  Obx(() {
                    final photoPath = widget.ctrl.userProfile.photoPath;
                    return Container(
                      width: 120, height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: photoPath != null
                                ? AppColors.primary
                                : AppColors.divider,
                            width: 2),
                        color: AppColors.background,
                      ),
                      child: photoPath != null && File(photoPath).existsSync()
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(photoPath),
                                fit: BoxFit.cover,
                                width: 120, height: 160,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person, size: 50,
                                    color: AppColors.textSecondary),
                                const SizedBox(height: 4),
                                Text(isId ? 'Foto 3x4' : 'Photo 3x4',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                    );
                  }),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _pickPhoto(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, size: 16),
                        label: Text(isId ? 'Kamera' : 'Camera'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _pickPhoto(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library, size: 16),
                        label: Text(isId ? 'Galeri' : 'Gallery'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Form fields dengan auto-save
            _buildField(isId ? 'Nama Lengkap' : 'Full Name', _nameCtrl,
                onChanged: (_) => _autoSave()),
            _buildField(isId ? 'Email' : 'Email', _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => _autoSave()),
            _buildField(isId ? 'Nomor HP' : 'Phone Number', _phoneCtrl,
                keyboardType: TextInputType.phone,
                onChanged: (_) => _autoSave()),
            _buildField(isId ? 'Alamat' : 'Address', _addressCtrl,
                maxLines: 2, onChanged: (_) => _autoSave()),
            _buildField(isId ? 'Kota' : 'City', _cityCtrl,
                onChanged: (_) => _autoSave()),

            const SizedBox(height: 16),
            // Tombol Save manual juga ada
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _autoSave();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isId ? '✅ Data tersimpan!' : '✅ Data saved!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: Text(isId ? 'Simpan Data' : 'Save Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType? keyboardType, int maxLines = 1,
      void Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
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
    final isId = ctrl.locale.languageCode == 'id';
    return Scaffold(
      body: Obx(() => ctrl.userProfile.education.isEmpty
          ? Center(child: Text(isId ? 'Belum ada pendidikan' : 'No education yet',
              style: const TextStyle(color: AppColors.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ctrl.userProfile.education.length,
              itemBuilder: (_, i) {
                final edu = ctrl.userProfile.education[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.school, color: AppColors.primary),
                    title: Text(edu.institution,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${edu.degree} - ${edu.major}\n${edu.graduationYear}${edu.gpa.isNotEmpty ? ' | GPA: ${edu.gpa}' : ''}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () {
                        final p = ctrl.userProfile;
                        p.education.removeAt(i);
                        ctrl.updateUserProfile(p);
                      },
                    ),
                  ),
                );
              },
            )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAdd(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(isId ? 'Tambah' : 'Add',
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAdd(BuildContext context) {
    final isId = ctrl.locale.languageCode == 'id';
    final inst = TextEditingController();
    final deg  = TextEditingController();
    final maj  = TextEditingController();
    final yr   = TextEditingController();
    final gpa  = TextEditingController();
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
          children: [
            Text(isId ? 'Tambah Pendidikan' : 'Add Education',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(controller: inst,
                decoration: InputDecoration(labelText: isId ? 'Institusi' : 'Institution')),
            const SizedBox(height: 8),
            TextField(controller: deg,
                decoration: InputDecoration(labelText: isId ? 'Jenjang (S1/SMK/dll)' : 'Degree')),
            const SizedBox(height: 8),
            TextField(controller: maj,
                decoration: InputDecoration(labelText: isId ? 'Jurusan' : 'Major')),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(controller: yr,
                  decoration: InputDecoration(labelText: isId ? 'Tahun Lulus' : 'Year'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: gpa,
                  decoration: const InputDecoration(labelText: 'GPA/Nilai'))),
            ]),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (inst.text.isEmpty) return;
                  final p = ctrl.userProfile;
                  p.education.add(Education(
                    id: const Uuid().v4(),
                    institution: inst.text,
                    degree: deg.text,
                    major: maj.text,
                    graduationYear: yr.text,
                    gpa: gpa.text,
                  ));
                  ctrl.updateUserProfile(p);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isId ? '✅ Pendidikan ditambahkan!' : '✅ Education added!'),
                        backgroundColor: AppColors.success),
                  );
                },
                child: Text(isId ? 'Simpan' : 'Save'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Experience Tab
class _ExperienceTab extends StatelessWidget {
  final AppController ctrl;
  const _ExperienceTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isId = ctrl.locale.languageCode == 'id';
    return Scaffold(
      body: Obx(() => ctrl.userProfile.experience.isEmpty
          ? Center(child: Text(isId ? 'Belum ada pengalaman' : 'No experience yet',
              style: const TextStyle(color: AppColors.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ctrl.userProfile.experience.length,
              itemBuilder: (_, i) {
                final exp = ctrl.userProfile.experience[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.work, color: AppColors.primary),
                    title: Text(exp.position,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${exp.company}\n${exp.startDate} - ${exp.currentlyWorking ? "Sekarang" : exp.endDate}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () {
                        final p = ctrl.userProfile;
                        p.experience.removeAt(i);
                        ctrl.updateUserProfile(p);
                      },
                    ),
                  ),
                );
              },
            )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAdd(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(isId ? 'Tambah' : 'Add',
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAdd(BuildContext context) {
    final isId = ctrl.locale.languageCode == 'id';
    final comp = TextEditingController();
    final pos  = TextEditingController();
    final start= TextEditingController();
    final end  = TextEditingController();
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
              Text(isId ? 'Tambah Pengalaman' : 'Add Experience',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(controller: comp,
                  decoration: InputDecoration(labelText: isId ? 'Perusahaan' : 'Company')),
              const SizedBox(height: 8),
              TextField(controller: pos,
                  decoration: InputDecoration(labelText: isId ? 'Posisi' : 'Position')),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextField(controller: start,
                    decoration: InputDecoration(labelText: isId ? 'Mulai (2020)' : 'Start'))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: end,
                    enabled: !current,
                    decoration: InputDecoration(labelText: isId ? 'Selesai' : 'End'))),
              ]),
              CheckboxListTile(
                value: current,
                onChanged: (v) => setS(() => current = v!),
                title: Text(isId ? 'Masih bekerja' : 'Currently working',
                    style: const TextStyle(fontSize: 13)),
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
              ),
              TextField(controller: desc, maxLines: 2,
                  decoration: InputDecoration(labelText: isId ? 'Deskripsi' : 'Description')),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (comp.text.isEmpty || pos.text.isEmpty) return;
                    final p = ctrl.userProfile;
                    p.experience.add(Experience(
                      id: const Uuid().v4(),
                      company: comp.text,
                      position: pos.text,
                      startDate: start.text,
                      endDate: end.text,
                      currentlyWorking: current,
                      description: desc.text,
                    ));
                    ctrl.updateUserProfile(p);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isId ? '✅ Pengalaman ditambahkan!' : '✅ Experience added!'),
                          backgroundColor: AppColors.success),
                    );
                  },
                  child: Text(isId ? 'Simpan' : 'Save'),
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
    final isId = ctrl.locale.languageCode == 'id';
    return Scaffold(
      body: Obx(() => ctrl.userProfile.skills.isEmpty
          ? Center(child: Text(isId ? 'Belum ada keahlian' : 'No skills yet',
              style: const TextStyle(color: AppColors.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ctrl.userProfile.skills.length,
              itemBuilder: (_, i) {
                final skill = ctrl.userProfile.skills[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.star, color: AppColors.primary),
                    title: Text(skill.name),
                    subtitle: Text(_levelLabel(skill.level, isId)),
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
        onPressed: () => _showAdd(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(isId ? 'Tambah' : 'Add',
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  String _levelLabel(SkillLevel l, bool isId) {
    switch(l) {
      case SkillLevel.beginner:     return isId ? 'Pemula' : 'Beginner';
      case SkillLevel.intermediate: return isId ? 'Menengah' : 'Intermediate';
      case SkillLevel.advanced:     return isId ? 'Mahir' : 'Advanced';
      case SkillLevel.expert:       return isId ? 'Ahli' : 'Expert';
    }
  }

  void _showAdd(BuildContext context) {
    final isId = ctrl.locale.languageCode == 'id';
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
              Text(isId ? 'Tambah Keahlian' : 'Add Skill',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(controller: name,
                  decoration: InputDecoration(labelText: isId ? 'Nama Keahlian' : 'Skill Name')),
              const SizedBox(height: 12),
              Text(isId ? 'Tingkat Keahlian:' : 'Skill Level:'),
              ...SkillLevel.values.map((lv) => RadioListTile<SkillLevel>(
                value: lv, groupValue: level,
                onChanged: (v) => setS(() => level = v!),
                title: Text(_levelLabel(lv, isId)),
                activeColor: AppColors.primary,
                dense: true,
              )),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (name.text.isEmpty) return;
                    final p = ctrl.userProfile;
                    p.skills.add(Skill(id: const Uuid().v4(), name: name.text, level: level));
                    ctrl.updateUserProfile(p);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isId ? '✅ Keahlian ditambahkan!' : '✅ Skill added!'),
                          backgroundColor: AppColors.success),
                    );
                  },
                  child: Text(isId ? 'Simpan' : 'Save'),
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
