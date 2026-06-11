import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/ble_service.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';

/// State management untuk seluruh data helm.
///
/// Satu sumber kebenaran (single source of truth) untuk:
/// - Status koneksi BLE
/// - Data sensor (suhu, kelembapan, baterai)
/// - Kontrol kipas & mode
/// - Tracking perjalanan
class HelmetProvider extends ChangeNotifier {
  final BleService _bleService = BleService();
  final TripService _tripService = TripService();

  // ==================== SUBSCRIPTIONS ====================
  StreamSubscription? _tempSub;
  StreamSubscription? _humSub;
  StreamSubscription? _batSub;
  StreamSubscription? _fanSub;
  StreamSubscription? _modeSub;
  StreamSubscription? _connSub;

  // ==================== CONNECTION STATE ====================
  bool _isScanning = false;
  bool _isConnected = false;
  bool _isConnecting = false;
  String _deviceName = '';
  String _errorMessage = '';
  List<ScanResult> _scanResults = [];

  // ==================== SENSOR DATA ====================
  double _temperature = 0.0;
  double _humidity = 0.0;
  int _batteryLevel = 0;

  // ==================== CONTROL STATE ====================
  bool _fanIsOn = false;
  String _currentMode = 'Auto';

  // ==================== TRIP STATE ====================
  DateTime? _tripStartTime;
  final List<double> _tempReadings = [];
  final List<bool> _fanReadings = [];

  // ==================== GETTERS ====================
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String get deviceName => _deviceName;
  String get errorMessage => _errorMessage;
  List<ScanResult> get scanResults => _scanResults;

  double get temperature => _temperature;
  double get humidity => _humidity;
  int get batteryLevel => _batteryLevel;

  bool get fanIsOn => _fanIsOn;
  String get currentMode => _currentMode;

  BleService get bleService => _bleService;

  // ==================== SCAN ====================

  /// Mulai scan device BLE di sekitar
  Future<void> startScan() async {
    _isScanning = true;
    _errorMessage = '';
    _scanResults = [];
    notifyListeners();

    try {
      // Scan dan listen hasilnya
      _bleService.startScan(timeout: 8).listen(
        (results) {
          _scanResults = results;
          notifyListeners();
        },
        onDone: () {
          _isScanning = false;
          notifyListeners();
        },
        onError: (e) {
          _isScanning = false;
          _errorMessage = e.toString();
          notifyListeners();
        },
      );
    } catch (e) {
      _isScanning = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Hentikan scan
  Future<void> stopScan() async {
    await _bleService.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  // ==================== CONNECT ====================

  /// Hubungkan ke ESP32 device
  ///
  /// [device] didapat dari hasil scan.
  /// Setelah terhubung, otomatis subscribe ke data sensor.
  Future<void> connectToDevice(BluetoothDevice device) async {
    _isConnecting = true;
    _errorMessage = '';
    _deviceName = device.platformName.isNotEmpty
        ? device.platformName
        : device.remoteId.toString();
    notifyListeners();

    try {
      await _bleService.connectToDevice(device);
      _isConnected = true;
      _isConnecting = false;

      // Subscribe ke semua stream data
      _subscribeToStreams();

      // Mulai tracking perjalanan
      _startTrip();

      notifyListeners();
    } catch (e) {
      _isConnecting = false;
      _isConnected = false;
      _errorMessage = 'Gagal terhubung: $e';
      notifyListeners();
    }
  }

  /// Putuskan koneksi dari ESP32
  Future<void> disconnect() async {
    // Akhiri trip sebelum disconnect
    _endTrip();

    await _bleService.disconnect();
    _cancelSubscriptions();

    _isConnected = false;
    _isConnecting = false;
    _deviceName = '';
    _temperature = 0.0;
    _humidity = 0.0;
    _batteryLevel = 0;
    _fanIsOn = false;
    _currentMode = 'Auto';

    notifyListeners();
  }

  // ==================== CONTROLS ====================

  /// Toggle kipas ON/OFF
  Future<void> toggleFan() async {
    final newState = !_fanIsOn;
    await _bleService.sendFanCommand(newState);
    _fanIsOn = newState;
    notifyListeners();
  }

  /// Set kipas ke state tertentu
  Future<void> setFanState(bool isOn) async {
    await _bleService.sendFanCommand(isOn);
    _fanIsOn = isOn;
    notifyListeners();
  }

  /// Ganti mode helm
  ///
  /// [mode] bisa: "Normal", "Turbo", "Auto", "Manual"
  Future<void> setMode(String mode) async {
    await _bleService.sendModeCommand(mode);
    _currentMode = mode;
    notifyListeners();
  }

  // ==================== TRIPS ====================

  /// Mulai tracking perjalanan baru
  void _startTrip() {
    _tripStartTime = DateTime.now();
    _tempReadings.clear();
    _fanReadings.clear();
  }

  /// Akhiri perjalanan dan simpan ke Hive
  void _endTrip() {
    if (_tripStartTime == null) return;

    final endTime = DateTime.now();

    // Hitung rata-rata suhu
    double avgTemp = 0;
    if (_tempReadings.isNotEmpty) {
      avgTemp = _tempReadings.reduce((a, b) => a + b) /
          _tempReadings.length;
    }

    // Hitung rata-rata kelembapan (dari data yang tersedia)
    double avgHum = _humidity;

    // Hitung persentase penggunaan kipas
    double fanPercent = 0;
    if (_fanReadings.isNotEmpty) {
      final fanOnCount = _fanReadings.where((f) => f).length;
      fanPercent = (fanOnCount / _fanReadings.length) * 100;
    }

    // Hitung score
    final score = TripModel.calculateScore(
      avgTemp: avgTemp,
      fanPercent: fanPercent,
    );

    // Buat nama trip berdasarkan waktu
    final title = _generateTripTitle(_tripStartTime!);

    // Buat model trip
    final trip = TripModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      startTime: _tripStartTime!,
      endTime: endTime,
      avgTemperature: double.parse(avgTemp.toStringAsFixed(1)),
      avgHumidity: double.parse(avgHum.toStringAsFixed(1)),
      score: score,
      fanUsagePercent: double.parse(fanPercent.toStringAsFixed(1)),
    );

    // Simpan ke Hive
    _tripService.saveTrip(trip);

    // Reset
    _tripStartTime = null;
    _tempReadings.clear();
    _fanReadings.clear();
  }

  /// Generate nama trip berdasarkan waktu mulai
  String _generateTripTitle(DateTime start) {
    final hour = start.hour;
    if (hour >= 5 && hour < 11) {
      return 'Perjalanan Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Perjalanan Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Perjalanan Sore';
    } else {
      return 'Perjalanan Malam';
    }
  }

  /// Ambil semua trip dari Hive
  List<TripModel> getAllTrips() => _tripService.getAllTrips();

  /// Hapus trip berdasarkan id
  Future<void> deleteTrip(String id) async {
    await _tripService.deleteTrip(id);
    notifyListeners();
  }

  // ==================== PRIVATE ====================

  /// Subscribe ke semua stream data dari BLE
  void _subscribeToStreams() {
    _tempSub = _bleService.temperatureStream.listen((temp) {
      _temperature = temp;
      _tempReadings.add(temp); // Simpan untuk hitung rata-rata trip
      notifyListeners();
    });

    _humSub = _bleService.humidityStream.listen((hum) {
      _humidity = hum;
      notifyListeners();
    });

    _batSub = _bleService.batteryStream.listen((level) {
      _batteryLevel = level;
      notifyListeners();
    });

    _fanSub = _bleService.fanStateStream.listen((state) {
      _fanIsOn = state;
      _fanReadings.add(state); // Simpan untuk hitung efisiensi trip
      notifyListeners();
    });

    _modeSub = _bleService.modeStream.listen((mode) {
      _currentMode = mode;
      notifyListeners();
    });

    _connSub = _bleService.connectionStateStream.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _endTrip();
        _isConnected = false;
        _isConnecting = false;
        notifyListeners();
      }
    });
  }

  /// Batalkan semua subscription
  void _cancelSubscriptions() {
    _tempSub?.cancel();
    _humSub?.cancel();
    _batSub?.cancel();
    _fanSub?.cancel();
    _modeSub?.cancel();
    _connSub?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    _bleService.dispose();
    super.dispose();
  }
}
