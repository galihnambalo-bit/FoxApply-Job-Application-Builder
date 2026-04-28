import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/user_profile.dart';
import '../../controllers/app_controller.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AppController>();
    final isId = ctrl.locale.languageCode == 'id';

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Icon(Icons.history, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(isId ? 'Riwayat Lamaran' : 'Application History'),
        ]),
      ),
      body: Obx(() {
        if (ctrl.applicationHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📋', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text(
                  isId ? 'Belum ada riwayat' : 'No history yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  isId
                      ? 'Buat paket lamaran pertamamu!\nRiwayat akan muncul di sini.'
                      : 'Create your first application!\nHistory will appear here.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(isId ? 'Kembali ke Beranda' : 'Back to Home'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.applicationHistory.length,
          itemBuilder: (_, i) {
            final h = ctrl.applicationHistory[i];
            return _HistoryCard(
              history: h,
              isId: isId,
              onDuplicate: () {
                ctrl.duplicateApplication(h);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(isId
                      ? '✅ Data disalin! Tinggal ganti nama perusahaan'
                      : '✅ Data copied! Just change company name'),
                  backgroundColor: AppColors.success,
                ));
                Get.back();
              },
              onDelete: () => _confirmDelete(context, ctrl, h.id, isId),
              onOpen: () => OpenFilex.open(h.pdfPath),
              onStatusChange: (s) => ctrl.updateHistoryStatus(h.id, s),
            );
          },
        );
      }),
    );
  }

  void _confirmDelete(BuildContext ctx, AppController ctrl, String id, bool isId) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(isId ? 'Hapus Riwayat?' : 'Delete History?'),
        content: Text(isId ? 'Yakin ingin menghapus riwayat ini?' : 'Sure to delete this history?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isId ? 'Batal' : 'Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () { ctrl.removeHistory(id); Navigator.pop(ctx); },
            child: Text(isId ? 'Hapus' : 'Delete'),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ApplicationHistory history;
  final bool isId;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onOpen;
  final Function(String) onStatusChange;

  const _HistoryCard({
    required this.history,
    required this.isId,
    required this.onDuplicate,
    required this.onDelete,
    required this.onOpen,
    required this.onStatusChange,
  });

  Color _statusColor(String s) {
    switch (s) {
      case 'interview': return AppColors.accent;
      case 'accepted':  return AppColors.success;
      case 'rejected':  return AppColors.error;
      default:          return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(history.position,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.business, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(history.companyName,
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(history.date,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ])),
            // Status badge
            GestureDetector(
              onTap: () => _showStatusPicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(history.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _statusColor(history.status).withValues(alpha: 0.4)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    ApplicationHistory.statusLabel[history.status] ?? history.status,
                    style: TextStyle(fontSize: 11, color: _statusColor(history.status),
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, size: 14, color: _statusColor(history.status)),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          // Action buttons
          Row(children: [
            _ActionBtn(icon: Icons.picture_as_pdf, label: isId ? 'Buka' : 'Open',
                color: AppColors.primary, onTap: onOpen),
            const SizedBox(width: 8),
            _ActionBtn(icon: Icons.copy_all, label: isId ? 'Duplikat' : 'Duplicate',
                color: AppColors.accent, onTap: onDuplicate),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
              tooltip: isId ? 'Hapus' : 'Delete',
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ]),
        ]),
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(isId ? 'Update Status Lamaran' : 'Update Application Status',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...ApplicationHistory.statusLabel.entries.map((e) => RadioListTile<String>(
            value: e.key,
            groupValue: history.status,
            onChanged: (v) { onStatusChange(v!); Navigator.pop(context); },
            title: Text(e.value),
            activeColor: AppColors.primary,
          )),
        ]),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
