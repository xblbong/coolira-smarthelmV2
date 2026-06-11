import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Service untuk semua operasi BLE (scan, connect, read, write, notify)
///
/// UUID harus sama persis dengan yang ada di kode ESP32-C3.
/// Jika mengubah UUID di ESP32, harus diubah juga di sini.
class BleService {
  // ==================== UUID (sama dengan ESP32) ====================
  static const String serviceUuid =
      "12345678-1234-5678-1234-56789abcdef0";

  static const String tempCharUuid =
      "12345678-1234-5678-1234-56789abcdef1";

  static const String humidityCharUuid =
      "12345678-1234-5678-1234-56789abcdef2";

  static const String fanControlCharUuid =
      "12345678-1234-5678-1234-56789abcdef3";

  static const String modeCharUuid =
      "12345678-1234-5678-1234-56789abcdef4";

  static const String batteryCharUuid =
      "12345678-1234-5678-1234-56789abcdef5";

  // ==================== STATE ====================
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _tempCharacteristic;
  BluetoothCharacteristic? _humidityCharacteristic;
  BluetoothCharacteristic? _fanControlCharacteristic;
  BluetoothCharacteristic? _modeCharacteristic;
  BluetoothCharacteristic? _batteryCharacteristic;

  // Stream controllers untuk broadcast data ke UI
  final _temperatureController = StreamController<double>.broadcast();
  final _humidityController = StreamController<double>.broadcast();
  final _batteryController = StreamController<int>.broadcast();
  final _fanStateController = StreamController<bool>.broadcast();
  final _modeController = StreamController<String>.broadcast();
  final _connectionStateController =
      StreamController<BluetoothConnectionState>.broadcast();

  // ==================== PUBLIC STREAMS ====================
  /// Stream data suhu dari ESP32 (dalam derajat Celsius)
  Stream<double> get temperatureStream => _temperatureController.stream;

  /// Stream data kelembapan dari ESP32 (dalam persen)
  Stream<double> get humidityStream => _humidityController.stream;

  /// Stream level baterai dari ESP32 (dalam persen, 0-100)
  Stream<int> get batteryStream => _batteryController.stream;

  /// Stream status kipas (true = ON, false = OFF)
  Stream<bool> get fanStateStream => _fanStateController.stream;

  /// Stream mode saat ini (Normal/Turbo/Auto/Manual)
  Stream<String> get modeStream => _modeController.stream;

  /// Stream status koneksi BLE
  Stream<BluetoothConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  // ==================== PUBLIC GETTERS ====================
  /// Device yang sedang terhubung (null jika tidak terhubung)
  BluetoothDevice? get connectedDevice => _connectedDevice;

  /// Apakah sedang terhubung ke ESP32
  bool get isConnected => _connectedDevice != null;

  // ==================== SCAN ====================

  /// Mulai scan untuk device BLE yang sedang advertise.
  /// Mengembalikan stream dari hasil scan.
  ///
  /// Scan berhenti otomatis setelah [timeout] detik.
  Stream<List<ScanResult>> startScan({int timeout = 5}) async* {
    // Pastikan adapter BLE menyala
    if (await FlutterBluePlus.isSupported == false) {
      throw Exception("Bluetooth tidak didukung di device ini");
    }

    // Cek apakah Bluetooth menyala
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      throw Exception("Bluetooth belum dinyalakan. Silakan nyalakan Bluetooth.");
    }

    // Mulai scan
    await FlutterBluePlus.startScan(
      timeout: Duration(seconds: timeout),
      androidUsesFineLocation: true,
    );

    // Yield hasil scan secara real-time
    yield* FlutterBluePlus.onScanResults;
  }

  /// Hentikan scan yang sedang berjalan
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  // ==================== CONNECT ====================

  /// Hubungkan ke ESP32 device.
  ///
  /// [device] adalah device yang didapat dari hasil scan.
  /// Setelah terhubung, otomatis discover services dan subscribe ke notify.
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      // Simpan device
      _connectedDevice = device;

      // Hubungkan ke device
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      // Listen perubahan status koneksi
      device.connectionState.listen((state) {
        _connectionStateController.add(state);

        // Jika terputus, cleanup
        if (state == BluetoothConnectionState.disconnected) {
          _cleanupConnection();
        }
      });

      // Discover services
      await _discoverServices();
    } catch (e) {
      _cleanupConnection();
      rethrow;
    }
  }

  /// Putuskan koneksi dari ESP32
  Future<void> disconnect() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
    } finally {
      _cleanupConnection();
    }
  }

  // ==================== READ DATA ====================

  /// Baca suhu dari ESP32 (one-shot read)
  Future<double> readTemperature() async {
    if (_tempCharacteristic == null) return 0.0;

    final value = await _tempCharacteristic!.read();
    final str = String.fromCharCodes(value);
    return double.tryParse(str) ?? 0.0;
  }

  /// Baca kelembapan dari ESP32 (one-shot read)
  Future<double> readHumidity() async {
    if (_humidityCharacteristic == null) return 0.0;

    final value = await _humidityCharacteristic!.read();
    final str = String.fromCharCodes(value);
    return double.tryParse(str) ?? 0.0;
  }

  /// Baca status kipas dari ESP32
  Future<bool> readFanState() async {
    if (_fanControlCharacteristic == null) return false;

    final value = await _fanControlCharacteristic!.read();
    final str = String.fromCharCodes(value).trim();
    return str.toUpperCase() == "ON";
  }

  /// Baca mode dari ESP32
  Future<String> readMode() async {
    if (_modeCharacteristic == null) return "Auto";

    final value = await _modeCharacteristic!.read();
    return String.fromCharCodes(value).trim();
  }

  /// Baca level baterai dari ESP32
  Future<int> readBattery() async {
    if (_batteryCharacteristic == null) return 0;

    final value = await _batteryCharacteristic!.read();
    final str = String.fromCharCodes(value);
    return int.tryParse(str) ?? 0;
  }

  // ==================== WRITE COMMANDS ====================

  /// Kirim perintah ON/OFF kipas ke ESP32
  ///
  /// [isOn] true untuk nyalakan kipas, false untuk matikan
  Future<void> sendFanCommand(bool isOn) async {
    if (_fanControlCharacteristic == null) return;

    final command = isOn ? "ON" : "OFF";
    await _fanControlCharacteristic!.write(command.codeUnits);
  }

  /// Kirim perintah ganti mode ke ESP32
  ///
  /// [mode] bisa: "Normal", "Turbo", "Auto", "Manual"
  Future<void> sendModeCommand(String mode) async {
    if (_modeCharacteristic == null) return;

    await _modeCharacteristic!.write(mode.codeUnits);
  }

  // ==================== PRIVATE METHODS ====================

  /// Discover services dan characteristics dari ESP32,
  /// lalu subscribe ke notify untuk data real-time
  Future<void> _discoverServices() async {
    if (_connectedDevice == null) return;

    final services = await _connectedDevice!.discoverServices();

    for (final service in services) {
      // Cari service kita berdasarkan UUID
      if (service.uuid.toString().toLowerCase() !=
          serviceUuid.toLowerCase()) {
        continue;
      }

      // Service ditemukan! Sekarang cari semua characteristics
      for (final char in service.characteristics) {
        final uuid = char.uuid.toString().toLowerCase();

        if (uuid == tempCharUuid.toLowerCase()) {
          _tempCharacteristic = char;
          await _subscribeToNotify(char, (value) {
            final temp = double.tryParse(String.fromCharCodes(value)) ?? 0.0;
            _temperatureController.add(temp);
          });
        }
        else if (uuid == humidityCharUuid.toLowerCase()) {
          _humidityCharacteristic = char;
          await _subscribeToNotify(char, (value) {
            final hum = double.tryParse(String.fromCharCodes(value)) ?? 0.0;
            _humidityController.add(hum);
          });
        }
        else if (uuid == fanControlCharUuid.toLowerCase()) {
          _fanControlCharacteristic = char;
          await _subscribeToNotify(char, (value) {
            final state =
                String.fromCharCodes(value).trim().toUpperCase() == "ON";
            _fanStateController.add(state);
          });
        }
        else if (uuid == modeCharUuid.toLowerCase()) {
          _modeCharacteristic = char;
          await _subscribeToNotify(char, (value) {
            final mode = String.fromCharCodes(value).trim();
            _modeController.add(mode);
          });
        }
        else if (uuid == batteryCharUuid.toLowerCase()) {
          _batteryCharacteristic = char;
          await _subscribeToNotify(char, (value) {
            final level =
                int.tryParse(String.fromCharCodes(value)) ?? 0;
            _batteryController.add(level);
          });
        }
      }
    }
  }

  /// Subscribe ke characteristic notify.
  /// Setiap kali ESP32 mengirim data baru, [onData] dipanggil.
  Future<void> _subscribeToNotify(
    BluetoothCharacteristic char,
    void Function(List<int> value) onData,
  ) async {
    // Pastikan characteristic support notify
    if (char.properties.notify) {
      await char.setNotifyValue(true);
      char.onValueReceived.listen(onData);
    }
  }

  /// Cleanup saat koneksi terputus
  void _cleanupConnection() {
    _connectedDevice = null;
    _tempCharacteristic = null;
    _humidityCharacteristic = null;
    _fanControlCharacteristic = null;
    _modeCharacteristic = null;
    _batteryCharacteristic = null;
  }

  /// Dispose semua stream controllers
  void dispose() {
    _temperatureController.close();
    _humidityController.close();
    _batteryController.close();
    _fanStateController.close();
    _modeController.close();
    _connectionStateController.close();
  }
}
