import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

/// Widget info cuaca dan waktu.
/// Menampilkan waktu saat ini dan suhu dari sensor ESP32.
class WeatherInfo extends StatelessWidget {
  final String temperature;

  const WeatherInfo({
    super.key,
    this.temperature = '0°',
  });

  @override
  Widget build(BuildContext context) {
    // Ambil waktu saat ini
    final now = TimeOfDay.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final time = '$hour:$minute';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.skyBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 6),
          const Icon(Icons.wb_sunny_rounded, color: AppColors.yellow, size: 22),
          const SizedBox(height: 6),
          Text(
            temperature,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.deepBlue,
            ),
          ),
        ],
      ),
    );
  }
}
