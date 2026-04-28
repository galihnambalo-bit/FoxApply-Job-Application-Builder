// lib/presentation/screens/cover_letter/cover_letter_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_profile.dart';
import '../../controllers/app_controller.dart';
import 'package:foxapply/l10n/app_localizations.dart';

class CoverLetterScreen extends StatefulWidget {
  const CoverLetterScreen({super.key});

  @override
  State<CoverLetterScreen> createState() => _CoverLetterScreenState();
}

class _CoverLetterScreenState extends State<CoverLetterScreen> {
  final _ctrl = Get.find<AppController>();
  late TextEditingController _positionCtrl;
  late TextEditingController _companyCtrl;
  late TextEditingController _deptCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _contentCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final job = _ctrl.jobApplication;
    _positionCtrl = TextEditingController(text: job.targetPosition);
    _companyCtrl = TextEditingController(text: job.targetCompany);
    _deptCtrl = TextEditingController(text: job.targetDepartment);
    _dateCtrl = TextEditingController(text: job.applicationDate);
    _contentCtrl = TextEditingController(text: job.customLetterContent);
  }

  @override
  void dispose() {
    _positionCtrl.dispose();
    _companyCtrl.dispose();
    _deptCtrl.dispose();
    _dateCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _ctrl.updateJobApplication(JobApplication(
      targetPosition: _positionCtrl.text,
      targetCompany: _companyCtrl.text,
      targetDepartment: _deptCtrl.text,
      applicationDate: _dateCtrl.text,
      customLetterContent: _contentCtrl.text,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.successSaved)),
    );
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.coverLetterBuilder),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l.save,
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
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l.generateLetter,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _positionCtrl,
                decoration: InputDecoration(labelText: l.targetPosition),
                validator: (v) =>
                    v!.isEmpty ? l.errorRequired : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _companyCtrl,
                decoration: InputDecoration(labelText: l.targetCompany),
                validator: (v) =>
                    v!.isEmpty ? l.errorRequired : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _deptCtrl,
                decoration: const InputDecoration(labelText: 'Department (Optional)'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _dateCtrl,
                decoration: InputDecoration(
                  labelText: l.letterDate,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final dt = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (dt != null) {
                        _dateCtrl.text =
                            '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(l.letterContent,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentCtrl,
                maxLines: 12,
                decoration: InputDecoration(
                  hintText: l.generateLetter,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '* ${l.generateLetter}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
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
      ),
    );
  }
}
