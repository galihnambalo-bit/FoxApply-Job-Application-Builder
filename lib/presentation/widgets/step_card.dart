// lib/presentation/widgets/step_card.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StepCard extends StatelessWidget {
  final int step;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isComplete;
  final VoidCallback? onTap;

  const StepCard({
    super.key,
    required this.step,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isComplete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isComplete
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isComplete
                      ? const Icon(Icons.check, color: AppColors.success)
                      : Icon(icon, color: AppColors.primary, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isComplete
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isComplete ? '✓' : step.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isComplete
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// lib/presentation/widgets/fox_button.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FoxButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const FoxButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🦊', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }
}
