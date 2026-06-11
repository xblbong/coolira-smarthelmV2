import 'package:hive_flutter/hive_flutter.dart';
import '../models/trip_model.dart';

/// Service untuk menyimpan dan mengambil data perjalanan (trip)
/// menggunakan Hive (local NoSQL database di HP).
///
/// Data tersimpan di masing-masing HP, tidak perlu internet.
class TripService {
  static const String _boxName = 'trips_box';

  /// Inisialisasi Hive dan register adapter.
  /// Panggil sekali di main() sebelum runApp().
  static Future<void> init() async {
    await Hive.initFlutter();
    // Tidak perlu TypeAdapter karena kita simpan sebagai Map
    await Hive.openBox(_boxName);
  }

  /// Ambil semua trip dari database, diurutkan dari terbaru
  List<TripModel> getAllTrips() {
    final box = Hive.box(_boxName);
    final List<TripModel> trips = [];

    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i);
      if (data != null) {
        trips.add(_fromMap(Map<String, dynamic>.from(data)));
      }
    }

    // Urutkan dari terbaru ke terlama
    trips.sort((a, b) => b.startTime.compareTo(a.startTime));
    return trips;
  }

  /// Simpan trip baru ke database
  Future<void> saveTrip(TripModel trip) async {
    final box = Hive.box(_boxName);
    await box.add(_toMap(trip));
  }

  /// Hapus trip berdasarkan id
  Future<void> deleteTrip(String id) async {
    final box = Hive.box(_boxName);

    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i);
      if (data != null && data['id'] == id) {
        await box.deleteAt(i);
        break;
      }
    }
  }

  /// Hapus semua trip
  Future<void> clearAll() async {
    final box = Hive.box(_boxName);
    await box.clear();
  }

  /// Konversi TripModel ke Map untuk disimpan di Hive
  Map<String, dynamic> _toMap(TripModel trip) {
    return {
      'id': trip.id,
      'title': trip.title,
      'startTime': trip.startTime.toIso8601String(),
      'endTime': trip.endTime.toIso8601String(),
      'avgTemperature': trip.avgTemperature,
      'avgHumidity': trip.avgHumidity,
      'score': trip.score,
      'fanUsagePercent': trip.fanUsagePercent,
    };
  }

  /// Konversi Map dari Hive ke TripModel
  TripModel _fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      avgTemperature: (map['avgTemperature'] ?? 0).toDouble(),
      avgHumidity: (map['avgHumidity'] ?? 0).toDouble(),
      score: map['score'] ?? 0,
      fanUsagePercent: (map['fanUsagePercent'] ?? 0).toDouble(),
    );
  }
}
