import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// Item perjalanan dalam daftar riwayat
/// Menampilkan detail singkat perjalanan dengan status
class TripItemWidget extends StatelessWidget {
  final String title;
  final String date;
  final String distance;
  final String duration;
  final int score;
  final IconData icon;

  const TripItemWidget({
    super.key,
    required this.title,
    required this.date,
    required this.distance,
    required this.duration,
    required this.score,
    this.icon = Icons.motorcycle_rounded,
  });

  Color _getScoreColor() {
    if (score >= 80) return AppColors.green;
    if (score >= 60) return AppColors.yellow;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.skyBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.deepBlue, size: 24),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _infoChip(Icons.route_rounded, distance),
                    const SizedBox(width: 12),
                    _infoChip(Icons.schedule_rounded, duration),
                  ],
                ),
              ],
            ),
          ),
          // Score badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getScoreColor().withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$score',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _getScoreColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.darkGrey),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.darkGrey,
          ),
        ),
      ],
    );
  }
}
