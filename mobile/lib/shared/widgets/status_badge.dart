import 'package:flutter/material.dart';
import 'package:eventsync_mobile/core/theme/app_colors.dart';

/// Status badge chip used for tasks, events, vendors, rundowns.
class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize = 11});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'selesai':
        return AppColors.statusSelesai;
      case 'proses':
      case 'berjalan':
      case 'aktif':
        return AppColors.statusProses;
      case 'terkendala':
      case 'batal':
        return AppColors.statusTerkendala;
      case 'ditunda':
        return AppColors.rundownDitunda;
      case 'draft':
      case 'belum':
      default:
        return AppColors.statusBelum;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withAlpha(100)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Priority badge for tasks.
class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({super.key, required this.priority});

  Color get _color {
    switch (priority.toLowerCase()) {
      case 'kritis':
        return AppColors.priorityKritis;
      case 'tinggi':
        return AppColors.priorityTinggi;
      case 'sedang':
        return AppColors.prioritySedang;
      case 'rendah':
        return AppColors.priorityRendah;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (priority.toLowerCase()) {
      case 'kritis':
        return Icons.priority_high_rounded;
      case 'tinggi':
        return Icons.arrow_upward_rounded;
      case 'sedang':
        return Icons.remove_rounded;
      case 'rendah':
        return Icons.arrow_downward_rounded;
      default:
        return Icons.remove_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, color: _color, size: 14),
        const SizedBox(width: 4),
        Text(
          priority,
          style: TextStyle(
            color: _color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
