/*
 * ============================================================
 * COOLIRA SMART HELMET - ESP32-C3 Firmware
 * ============================================================
 *
 * Sistem helm pintar dengan pendingin otomatis.
 * Menggunakan BLE untuk komunikasi dengan Flutter App.
 *
 * Hardware:
 * - ESP32-C3 (WiFi + BLE built-in)
 * - DHT22 sensor (suhu & kelembapan)
 * - IRF520 MOSFET untuk kontrol kipas (PWM capable)
 * - Baterai lithium 3.7V
 *
 * Wiring:
 * - DHT22 VCC  → 3.3V
 * - DHT22 DATA → GPIO 5
 * - DHT22 GND  → GND
 * - IRF520 SIG  → GPIO 10
 * - IRF520 VCC  → VCC kipas
 * - IRF520 GND  → GND
 *
 * Library yang dibutuhkan:
 * - DHT sensor library (oleh Adafruit)
 * - ESP32 BLE Arduino (built-in di ESP32 board package)
 *
 * ============================================================
 */

#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <DHT.h>

// ==================== PIN DEFINITION ====================
#define DHTPIN        5        // Pin data DHT22
#define DHTTYPE       DHT22    // Tipe sensor
#define FAN_PIN       10       // Pin SIG IRF520 MOSFET (kipas)

// ==================== BLE UUID ====================
// UUID untuk service dan characteristics
// App Flutter harus pakai UUID yang sama persis

#define SERVICE_UUID              "12345678-1234-5678-1234-56789abcdef0"

#define TEMP_CHAR_UUID            "12345678-1234-5678-1234-56789abcdef1"
#define HUMIDITY_CHAR_UUID        "12345678-1234-5678-1234-56789abcdef2"
#define FAN_CONTROL_CHAR_UUID     "12345678-1234-5678-1234-56789abcdef3"
#define MODE_CHAR_UUID            "12345678-1234-5678-1234-56789abcdef4"
#define BATTERY_CHAR_UUID         "12345678-1234-5678-1234-56789abcdef5"

// ==================== BLE OBJECTS ====================
BLEServer*         pServer          = NULL;
BLECharacteristic* pTempChar        = NULL;
BLECharacteristic* pHumidityChar    = NULL;
BLECharacteristic* pFanControlChar  = NULL;
BLECharacteristic* pModeChar        = NULL;
BLECharacteristic* pBatteryChar     = NULL;

bool deviceConnected    = false;
bool oldDeviceConnected = false;

// ==================== SENSOR & CONTROL ====================
DHT dht(DHTPIN, DHTTYPE);

bool fanState       = true;      // Status kipas: true = ON, false = OFF
                                  // Default ON (sesuai kode asli)
String currentMode  = "Auto";    // Mode: Normal, Turbo, Auto, Manual
float temperature   = 0.0;       // Suhu dari DHT22
float humidity      = 0.0;       // Kelembapan dari DHT22
int batteryLevel    = 85;        // Battery level (dummy data)

// ==================== TIMING ====================
unsigned long lastSensorRead  = 0;
unsigned long lastBatteryRead = 0;
const unsigned long SENSOR_INTERVAL  = 2000;   // Baca sensor setiap 2 detik
const unsigned long BATTERY_INTERVAL = 30000;  // Baca baterai setiap 30 detik

// ==================== AUTO MODE THRESHOLD ====================
const float AUTO_TEMP_THRESHOLD = 30.0;  // Kipas ON otomatis jika suhu > 30°C

// ==================== PWM CONFIG (untuk Turbo mode nanti) ====================
// IRF520 mendukung PWM untuk kontrol kecepatan kipas
// Saat ini hanya ON/OFF, tapi sudah siap untuk PWM nanti
const int PWM_CHANNEL    = 0;
const int PWM_FREQ       = 25000;  // 25 kHz (cocok untuk fan)
const int PWM_RESOLUTION = 8;      // 8-bit (0-255)

// ==================== CALLBACK: Koneksi BLE ====================
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
    Serial.println("================================");
    Serial.println("DEVICE CONNECTED!");
    Serial.println("================================");
  }

  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
    Serial.println("================================");
    Serial.println("DEVICE DISCONNECTED");
    Serial.println("================================");
  }
};

// ==================== CALLBACK: Terima Perintah dari App ====================

// Callback untuk Fan Control characteristic
class FanControlCallback : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pCharacteristic) {
    String value = pCharacteristic->getValue().c_str();
    value.trim();

    Serial.print("Fan command received: ");
    Serial.println(value);

    if (value.equalsIgnoreCase("ON")) {
      fanState = true;
      digitalWrite(FAN_PIN, HIGH);
      Serial.println(">>> KIPAS ON");
    }
    else if (value.equalsIgnoreCase("OFF")) {
      fanState = false;
      digitalWrite(FAN_PIN, LOW);
      Serial.println(">>> KIPAS OFF");
    }

    // Kirim konfirmasi status kipas kembali ke app
    pFanControlChar->setValue(fanState ? "ON" : "OFF");
    if (deviceConnected) {
      pFanControlChar->notify();
    }
  }
};

// Callback untuk Mode characteristic
class ModeCallback : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pCharacteristic) {
    String value = pCharacteristic->getValue().c_str();
    value.trim();

    Serial.print("Mode command received: ");
    Serial.println(value);

    // Validasi mode
    if (value == "Normal" || value == "Turbo" ||
        value == "Auto"   || value == "Manual") {
      currentMode = value;
      Serial.print(">>> Mode changed to: ");
      Serial.println(currentMode);

      // Kirim konfirmasi mode kembali ke app
      pModeChar->setValue(currentMode.c_str());
      if (deviceConnected) {
        pModeChar->notify();
      }
    }
  }
};

// ==================== SETUP ====================
void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("================================");
  Serial.println("  COOLIRA SMART HELMET SYSTEM");
  Serial.println("  ESP32-C3 BLE Firmware v1.0");
  Serial.println("================================");

  // --- Setup Pin ---
  pinMode(FAN_PIN, OUTPUT);
  digitalWrite(FAN_PIN, HIGH);   // Kipas ON saat mulai (sesuai kode asli)

  // --- Setup DHT22 ---
  dht.begin();
  Serial.println("[OK] DHT22 sensor initialized");

  // --- Setup BLE ---
  setupBLE();

  Serial.println("================================");
  Serial.println("  SYSTEM READY!");
  Serial.println("  Waiting for app connection...");
  Serial.println("================================");
}

// ==================== LOOP ====================
void loop() {
  // --- Baca Sensor DHT22 ---
  if (millis() - lastSensorRead >= SENSOR_INTERVAL) {
    lastSensorRead = millis();
    readSensors();
    updateBLECharacteristics();
    handleAutoMode();
  }

  // --- Kirim Battery Level (dummy) ---
  if (millis() - lastBatteryRead >= BATTERY_INTERVAL) {
    lastBatteryRead = millis();
    if (deviceConnected) {
      pBatteryChar->setValue(String(batteryLevel).c_str());
      pBatteryChar->notify();
      Serial.print("[BAT] Level: ");
      Serial.print(batteryLevel);
      Serial.println("% (dummy)");
    }
  }

  // --- Handle Koneksi BLE ---
  // Jika device terputus, mulai advertising lagi
  if (!deviceConnected && oldDeviceConnected) {
    delay(500);  // Beri waktu untuk BLE stack cleanup
    pServer->startAdvertising();
    Serial.println(">>> BLE Advertising restarted (waiting for connection...)");
    oldDeviceConnected = deviceConnected;
  }

  // Jika baru terhubung
  if (deviceConnected && !oldDeviceConnected) {
    oldDeviceConnected = deviceConnected;
  }

  // --- Serial Monitor Commands (untuk debugging) ---
  handleSerialCommands();
}

// ==================== FUNGSI-FUNGSI ====================

/// Inisialisasi BLE Server, Service, dan Characteristics
void setupBLE() {
  Serial.println("[...] Initializing BLE...");

  // 1. Buat BLE Device dengan nama "CooliraHelmet"
  BLEDevice::init("CooliraHelmet");

  // 2. Buat BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // 3. Buat BLE Service
  BLEService* pService = pServer->createService(SERVICE_UUID);

  // 4. Buat Characteristics

  // Temperature (Read + Notify)
  pTempChar = pService->createCharacteristic(
    TEMP_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY
  );
  pTempChar->addDescriptor(new BLE2902());

  // Humidity (Read + Notify)
  pHumidityChar = pService->createCharacteristic(
    HUMIDITY_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY
  );
  pHumidityChar->addDescriptor(new BLE2902());

  // Fan Control (Read + Write + Notify)
  pFanControlChar = pService->createCharacteristic(
    FAN_CONTROL_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ    |
    BLECharacteristic::PROPERTY_WRITE   |
    BLECharacteristic::PROPERTY_NOTIFY
  );
  pFanControlChar->setCallbacks(new FanControlCallback());
  pFanControlChar->addDescriptor(new BLE2902());
  pFanControlChar->setValue("ON");  // Default ON

  // Mode (Read + Write + Notify)
  pModeChar = pService->createCharacteristic(
    MODE_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ    |
    BLECharacteristic::PROPERTY_WRITE   |
    BLECharacteristic::PROPERTY_NOTIFY
  );
  pModeChar->setCallbacks(new ModeCallback());
  pModeChar->addDescriptor(new BLE2902());
  pModeChar->setValue("Auto");

  // Battery (Read + Notify) - placeholder
  pBatteryChar = pService->createCharacteristic(
    BATTERY_CHAR_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY
  );
  pBatteryChar->addDescriptor(new BLE2902());

  // 5. Start Service
  pService->start();

  // 6. Start Advertising
  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // Untuk koneksi lebih cepat
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();

  Serial.println("[OK] BLE initialized");
  Serial.println("[OK] Device name: CooliraHelmet");
  Serial.println("[OK] Service UUID: " SERVICE_UUID);
  Serial.println("[OK] Advertising started");
}

/// Baca data dari sensor DHT22
void readSensors() {
  float t = dht.readTemperature();
  float h = dht.readHumidity();

  // Cek apakah pembacaan berhasil
  if (!isnan(t) && !isnan(h)) {
    temperature = t;
    humidity = h;

    Serial.print("[DHT22] Suhu: ");
    Serial.print(temperature);
    Serial.print(" °C | Kelembapan: ");
    Serial.print(humidity);
    Serial.print(" % | Kipas: ");
    Serial.print(fanState ? "ON" : "OFF");
    Serial.print(" | Mode: ");
    Serial.println(currentMode);
  } else {
    Serial.println("[DHT22] ERROR: Gagal membaca sensor!");
  }
}

/// Update BLE characteristics dengan data sensor terbaru
void updateBLECharacteristics() {
  if (!deviceConnected) return;

  // Kirim temperature
  pTempChar->setValue(String(temperature, 1).c_str());
  pTempChar->notify();

  // Kirim humidity
  pHumidityChar->setValue(String(humidity, 1).c_str());
  pHumidityChar->notify();
}

/// Handle mode Auto: kipas otomatis ON/OFF berdasarkan suhu
void handleAutoMode() {
  if (currentMode != "Auto") return;

  if (temperature >= AUTO_TEMP_THRESHOLD && !fanState) {
    // Suhu tinggi, nyalakan kipas
    fanState = true;
    digitalWrite(FAN_PIN, HIGH);
    pFanControlChar->setValue("ON");
    if (deviceConnected) pFanControlChar->notify();
    Serial.println("[AUTO] Suhu tinggi, kipas ON");
  }
  else if (temperature < (AUTO_TEMP_THRESHOLD - 2.0) && fanState) {
    // Suhu turun cukup jauh, matikan kipas (hysteresis 2°C)
    fanState = false;
    digitalWrite(FAN_PIN, LOW);
    pFanControlChar->setValue("OFF");
    if (deviceConnected) pFanControlChar->notify();
    Serial.println("[AUTO] Suhu normal, kipas OFF");
  }
}

/// Handle perintah dari Serial Monitor (untuk debugging)
void handleSerialCommands() {
  if (!Serial.available()) return;

  String cmd = Serial.readStringUntil('\n');
  cmd.trim();

  if (cmd.equalsIgnoreCase("on")) {
    fanState = true;
    digitalWrite(FAN_PIN, HIGH);
    Serial.println(">>> KIPAS ON (via Serial)");
  }
  else if (cmd.equalsIgnoreCase("off")) {
    fanState = false;
    digitalWrite(FAN_PIN, LOW);
    Serial.println(">>> KIPAS OFF (via Serial)");
  }
  else if (cmd.equalsIgnoreCase("status")) {
    Serial.println("=== STATUS ===");
    Serial.print("Suhu      : "); Serial.print(temperature); Serial.println(" °C");
    Serial.print("Kelembapan: "); Serial.print(humidity); Serial.println(" %");
    Serial.print("Kipas     : "); Serial.println(fanState ? "ON" : "OFF");
    Serial.print("Mode      : "); Serial.println(currentMode);
    Serial.print("Baterai   : "); Serial.print(batteryLevel); Serial.println(" %");
    Serial.print("BLE       : "); Serial.println(deviceConnected ? "Connected" : "Disconnected");
    Serial.println("==============");
  }
  else if (cmd.equalsIgnoreCase("help")) {
    Serial.println("=== COMMANDS ===");
    Serial.println("on      - Kipas ON");
    Serial.println("off     - Kipas OFF");
    Serial.println("status  - Lihat status sistem");
    Serial.println("help    - Tampilkan bantuan");
    Serial.println("================");
  }
  else {
    Serial.println("Unknown command. Type 'help' for commands.");
  }
}
