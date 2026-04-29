import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_profile.dart';
import '../../controllers/app_controller.dart';

class CoverLetterScreen extends StatefulWidget {
  const CoverLetterScreen({super.key});
  @override
  State<CoverLetterScreen> createState() => _CoverLetterScreenState();
}

class _CoverLetterScreenState extends State<CoverLetterScreen> {
  final _ctrl = Get.find<AppController>();
  late TextEditingController _posCtrl;
  late TextEditingController _compCtrl;
  late TextEditingController _deptCtrl;
  late TextEditingController _dateCtrl;
  final _formKey = GlobalKey<FormState>();
  bool _isId = true;

  // Daftar lampiran yang bisa diedit
  late List<TextEditingController> _attachmentCtrls;

  @override
  void initState() {
    super.initState();
    _isId = _ctrl.locale.languageCode == 'id';
    final job = _ctrl.jobApplication;
    _posCtrl  = TextEditingController(text: job.targetPosition);
    _compCtrl = TextEditingController(text: job.targetCompany);
    _deptCtrl = TextEditingController(text: job.targetDepartment);
    _dateCtrl = TextEditingController(text: job.applicationDate);

    // Default lampiran
    final defaultAttachments = _isId ? [
      'Daftar Riwayat Hidup (CV)',
      'Foto Copy Ijazah Terakhir',
      'Foto Copy KTP',
      'Foto Copy Transkrip Nilai',
      'Pas Foto 3x4',
    ] : [
      'Curriculum Vitae (CV)',
      'Copy of Latest Diploma',
      'Copy of ID Card',
      'Academic Transcript',
      'Passport Photo 3x4',
    ];
    _attachmentCtrls = defaultAttachments
        .map((a) => TextEditingController(text: a))
        .toList();
  }

  @override
  void dispose() {
    _posCtrl.dispose(); _compCtrl.dispose();
    _deptCtrl.dispose(); _dateCtrl.dispose();
    for (final c in _attachmentCtrls) c.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _ctrl.updateJobApplication(JobApplication(
      targetPosition: _posCtrl.text,
      targetCompany: _compCtrl.text,
      targetDepartment: _deptCtrl.text,
      applicationDate: _dateCtrl.text,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isId ? '✅ Info lamaran tersimpan!' : '✅ Job info saved!'),
        backgroundColor: AppColors.success,
      ),
    );
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isId ? 'Info Lamaran' : 'Job Application Info'),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save, color: AppColors.primary),
            label: Text(_isId ? 'Simpan' : 'Save',
                style: const TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info perusahaan
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isId
                            ? 'Isi info perusahaan → surat lamaran dibuat otomatis!'
                            : 'Fill company info → cover letter generated automatically!',
                        style: const TextStyle(fontSize: 12, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _posCtrl,
                decoration: InputDecoration(
                  labelText: _isId ? 'Posisi yang Dilamar *' : 'Position Applied *',
                  prefixIcon: const Icon(Icons.work_outline),
                ),
                validator: (v) => v!.isEmpty
                    ? (_isId ? 'Wajib diisi' : 'Required') : null,
                onChanged: (_) => _autoSave(),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _compCtrl,
                decoration: InputDecoration(
                  labelText: _isId ? 'Nama Perusahaan *' : 'Company Name *',
                  prefixIcon: const Icon(Icons.business_outlined),
                ),
                validator: (v) => v!.isEmpty
                    ? (_isId ? 'Wajib diisi' : 'Required') : null,
                onChanged: (_) => _autoSave(),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _deptCtrl,
                decoration: InputDecoration(
                  labelText: _isId ? 'Departemen (Opsional)' : 'Department (Optional)',
                  prefixIcon: const Icon(Icons.apartment_outlined),
                ),
                onChanged: (_) => _autoSave(),
              ),
              const SizedBox(height: 20),

              // Daftar lampiran yang bisa diedit
              Row(
                children: [
                  const Icon(Icons.attach_file, color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    _isId ? 'Daftar Lampiran:' : 'Attachments List:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _attachmentCtrls.add(TextEditingController());
                      });
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(_isId ? 'Tambah' : 'Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._attachmentCtrls.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${e.key + 1}',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.primary,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: e.value,
                        decoration: InputDecoration(
                          hintText: _isId ? 'Nama lampiran...' : 'Attachment name...',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: AppColors.error, size: 20),
                      onPressed: () {
                        setState(() {
                          _attachmentCtrls[e.key].dispose();
                          _attachmentCtrls.removeAt(e.key);
                        });
                      },
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: Text(_isId ? 'Simpan & Kembali' : 'Save & Back'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _autoSave() {
    _ctrl.updateJobApplication(JobApplication(
      targetPosition: _posCtrl.text,
      targetCompany: _compCtrl.text,
      targetDepartment: _deptCtrl.text,
      applicationDate: _dateCtrl.text,
    ));
  }
}
