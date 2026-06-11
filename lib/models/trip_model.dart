import 'package:hive/hive.dart';

/// Model data untuk perjalanan (trip).
///
/// Data ini disimpan secara lokal di Hive database
/// setiap kali ESP32 terhubung dan terputus.
///
/// Rumus Score:
///   score = (comfortScore * 0.6) + (efficiencyScore * 0.4)
///
///   comfortScore berdasarkan suhu rata-rata:
///     20-28°C → 100, 28-35°C → 70, >35°C → 40, <20°C → 80
///
///   efficiencyScore berdasarkan rasio kipas ON vs total waktu:
///     Semakin efisien → score lebih tinggi
class TripModel extends HiveObject {
  String id;
  String title;
  DateTime startTime;
  DateTime endTime;
  double avgTemperature;
  double avgHumidity;
  int score;
  double fanUsagePercent;

  TripModel({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.avgTemperature = 0.0,
    this.avgHumidity = 0.0,
    this.score = 0,
    this.fanUsagePercent = 0.0,
  });

  /// Durasi perjalanan dalam menit
  int get durationMinutes =>
      endTime.difference(startTime).inMinutes;

  /// Format durasi untuk tampilan (contoh: "25 mnt" atau "2j 15mnt")
  String get durationFormatted {
    final dur = endTime.difference(startTime);
    final hours = dur.inHours;
    final minutes = dur.inMinutes % 60;

    if (hours > 0) {
      return '${hours}j ${minutes}mnt';
    }
    return '${minutes} mnt';
  }

  /// Hitung score berdasarkan data perjalanan
  static int calculateScore({
    required double avgTemp,
    required double fanPercent,
  }) {
    // Comfort score berdasarkan suhu rata-rata
    double comfortScore;
    if (avgTemp >= 20 && avgTemp <= 28) {
      comfortScore = 100;
    } else if (avgTemp > 28 && avgTemp <= 35) {
      comfortScore = 70;
    } else if (avgTemp > 35) {
      comfortScore = 40;
    } else {
      // < 20°C
      comfortScore = 80;
    }

    // Efficiency score: semakin rendah penggunaan kipas = semakin efisien
    // Tapi kalau kipas 0% dan suhu tinggi, berarti tidak efektif
    double efficiencyScore;
    if (fanPercent <= 30) {
      efficiencyScore = 100;
    } else if (fanPercent <= 60) {
      efficiencyScore = 80;
    } else if (fanPercent <= 80) {
      efficiencyScore = 60;
    } else {
      efficiencyScore = 40;
    }

    return (comfortScore * 0.6 + efficiencyScore * 0.4).round();
  }
}
