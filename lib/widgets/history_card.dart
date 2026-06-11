import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import '../models/trip_model.dart';
import '../screens/riwayat/riwayat_screen.dart';

/// Kartu riwayat berkendara dengan 2 item (energi & waktu pakai).
///
/// Menampilkan ringkasan dari data trip yang tersimpan di Hive.
class HistoryCard extends StatelessWidget {
  final List<TripModel> trips;

  const HistoryCard({
    super.key,
    this.trips = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Hitung total waktu pakai dari semua trip
    final totalMinutes =
        trips.fold<int>(0, (sum, trip) => sum + trip.durationMinutes);

    // Format total waktu
    String totalTime;
    if (totalMinutes >= 60) {
      final hours = totalMinutes ~/ 60;
      final mins = totalMinutes % 60;
      totalTime = '${hours}j ${mins}mnt';
    } else {
      totalTime = '${totalMinutes}mnt';
    }

    // Hitung rata-rata efisiensi (score) dari semua trip
    double avgEfficiency = 0;
    if (trips.isNotEmpty) {
      avgEfficiency =
          trips.fold<double>(0, (sum, trip) => sum + trip.score) /
              trips.length;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Riwayat Berkendara",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RiwayatScreen(),
                    ),
                  );
                },
                child: Text(
                  "Lihat Semua",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.deepBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HistoryItem(
                  value: '${avgEfficiency.round()}%',
                  title: "Efisiensi Rata-rata",
                  subtitle: "dari ${trips.length} perjalanan",
                  customIcon: Image.asset(
                    'assets/images/sun-2.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Container(
                height: 50,
                width: 1,
                color: AppColors.lightGrey.withValues(alpha: 0.7),
              ),
              Expanded(
                child: _HistoryItem(
                  value: totalTime,
                  title: "Total Waktu Pakai",
                  subtitle: "Pendingin/Daya",
                  customIcon: Image.asset(
                    'assets/images/suryapanel.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Item individual dalam history card
class _HistoryItem extends StatelessWidget {
  final String value;
  final String title;
  final String subtitle;
  final Widget? customIcon;

  const _HistoryItem({
    required this.value,
    required this.title,
    required this.subtitle,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.skyBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: customIcon ?? const Icon(Icons.electric_bolt_rounded, color: AppColors.skyBlue, size: 26),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.deepBlue,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 9,
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
