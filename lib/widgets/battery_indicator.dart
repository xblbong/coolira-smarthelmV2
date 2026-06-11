import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

/// Widget indikator baterai dengan border dan icon
class BatteryIndicator extends StatelessWidget {
  final String percentage;

  const BatteryIndicator({
    super.key,
    this.percentage = '85%',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.skyBlue.withValues(alpha: 0.5),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.battery_std_rounded,
            color: AppColors.skyBlue,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            percentage,
            style: GoogleFonts.inter(
              color: AppColors.skyBlue,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
