import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/helmet_provider.dart';
import '../../models/trip_model.dart';
import '../../widgets/riwayat/gauge_score_widget.dart';
import '../../widgets/riwayat/stats_card_widget.dart';
import '../../widgets/riwayat/riding_chart_widget.dart';
import '../../widgets/riwayat/trip_item_widget.dart';

/// Halaman Riwayat Berkendara
/// Menampilkan skor, statistik, grafik aktivitas, dan daftar perjalanan.
/// Data diambil dari Hive database (lokal di HP).
class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFC),
      body: Consumer<HelmetProvider>(
        builder: (context, provider, _) {
          final trips = provider.getAllTrips();
          final avgScore = _calculateAvgScore(trips);
          final totalKm = _estimateTotalKm(trips);
          final totalMinutes =
              trips.fold<int>(0, (sum, t) => sum + t.durationMinutes);
          final avgEfficiency = _calculateAvgEfficiency(trips);

          return Stack(
            children: [
              // Gradient header background
              Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: AppColors.accentGrad,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(context),
                      const SizedBox(height: 20),
                      // Gauge + Stats
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildScoreAndStats(
                          avgScore: avgScore,
                          totalKm: totalKm,
                          totalMinutes: totalMinutes,
                          avgEfficiency: avgEfficiency,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Chart
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: RidingChartWidget(trips: trips),
                      ),
                      const SizedBox(height: 20),
                      // Section title
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Perjalanan Terakhir',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Trip list
                      if (trips.isEmpty)
                        _buildEmptyState()
                      else
                        ..._buildTripList(trips),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Hitung rata-rata score dari semua trip
  int _calculateAvgScore(List<TripModel> trips) {
    if (trips.isEmpty) return 0;
    final total = trips.fold<int>(0, (sum, t) => sum + t.score);
    return (total / trips.length).round();
  }

  /// Estimasi total km (berdasarkan durasi, ~30 km/jam rata-rata kota)
  double _estimateTotalKm(List<TripModel> trips) {
    final totalMinutes =
        trips.fold<int>(0, (sum, t) => sum + t.durationMinutes);
    return (totalMinutes / 60) * 30; // ~30 km/jam
  }

  /// Hitung rata-rata efisiensi
  int _calculateAvgEfficiency(List<TripModel> trips) {
    if (trips.isEmpty) return 0;
    final total =
        trips.fold<double>(0, (sum, t) => sum + t.fanUsagePercent);
    return 100 - (total / trips.length).round();
  }

  /// Format total waktu
  String _formatTotalTime(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return '${h}j ${m}m';
    }
    return '${minutes}m';
  }

  /// Header dengan tombol back dan judul
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Riwayat Berkendara',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Gauge score dan kartu statistik
  Widget _buildScoreAndStats({
    required int avgScore,
    required double totalKm,
    required int totalMinutes,
    required int avgEfficiency,
  }) {
    return Column(
      children: [
        // Gauge
        Container(
          padding:
              const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
          child: Center(
            child: GaugeScoreWidget(score: avgScore),
          ),
        ),
        const SizedBox(height: 14),
        // Stats row
        Row(
          children: [
            StatsCardWidget(
              icon: Icons.route_rounded,
              value: totalKm.toStringAsFixed(1),
              label: 'Total Km',
              iconColor: AppColors.deepBlue,
            ),
            const SizedBox(width: 12),
            StatsCardWidget(
              icon: Icons.access_time_rounded,
              value: _formatTotalTime(totalMinutes),
              label: 'Total Waktu',
              iconColor: AppColors.skyBlue,
            ),
            const SizedBox(width: 12),
            StatsCardWidget(
              icon: Icons.bolt_rounded,
              value: '$avgEfficiency%',
              label: 'Efisiensi',
              iconColor: AppColors.green,
            ),
          ],
        ),
      ],
    );
  }

  /// Tampilan saat tidak ada data trip
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: AppColors.darkGrey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada perjalanan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hubungkan ke ESP32 dan mulai berkendara\nuntuk mencatat perjalanan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.darkGrey.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Daftar perjalanan dari data Hive
  List<Widget> _buildTripList(List<TripModel> trips) {
    final months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final days = [
      '', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];

    return trips.map((trip) {
      final date = trip.startTime;
      final dayName = days[date.weekday];
      final monthName = months[date.month];
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      final dateStr =
          '$dayName, ${date.day} $monthName ${date.year} · $hour:$minute';

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: TripItemWidget(
          title: trip.title,
          date: dateStr,
          distance:
              '${_estimateTripKm(trip).toStringAsFixed(1)} km',
          duration: trip.durationFormatted,
          score: trip.score,
        ),
      );
    }).toList();
  }

  /// Estimasi jarak per trip berdasarkan durasi
  double _estimateTripKm(TripModel trip) {
    return (trip.durationMinutes / 60) * 30; // ~30 km/jam
  }
}
