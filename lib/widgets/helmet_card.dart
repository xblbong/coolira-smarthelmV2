import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import 'battery_indicator.dart';
import 'weather_info.dart';

/// Kartu helm utama dengan info suhu, kelembapan, gambar helm, dan kontrol.
///
/// Data diterima dari HelmetProvider dan ditampilkan secara real-time.
/// Status koneksi bisa diklik untuk navigasi ke halaman Scan BLE.
class HelmetCard extends StatelessWidget {
  final String deviceId;
  final String temperature;
  final String humidity;
  final String status;
  final bool isConnected;
  final int batteryPercent;
  final bool fanIsOn;
  final VoidCallback? onTapConnection;

  const HelmetCard({
    super.key,
    this.deviceId = 'CooliraHelmet',
    this.temperature = '0.0',
    this.humidity = '0.0',
    this.status = 'Terputus',
    this.isConnected = false,
    this.batteryPercent = 0,
    this.fanIsOn = false,
    this.onTapConnection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF93D5ED).withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row info
          _buildTopInfo(),
          const SizedBox(height: 5),

          // Ring Temperature & Helmet
          _buildTemperatureRing(),
          const SizedBox(height: 15),

          // Slider dot indikator
          _buildSliderIndicator(),
          const SizedBox(height: 8),
          Text(
            "Cara Penggunaan",
            style: GoogleFonts.inter(
              color: AppColors.darkGrey,
              fontSize: 11,
              decoration: TextDecoration.underline,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/iconId.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 6),
                Text(
                  deviceId,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: onTapConnection,
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isConnected ? AppColors.green : AppColors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isConnected ? status : 'Hubungkan',
                    style: GoogleFonts.inter(
                      color: isConnected ? AppColors.green : AppColors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      decoration: isConnected
                          ? TextDecoration.none
                          : TextDecoration.underline,
                    ),
                  ),
                  if (!isConnected) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.bluetooth_searching_rounded,
                      size: 14,
                      color: AppColors.red,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            BatteryIndicator(percentage: '$batteryPercent%'),
          ],
        ),
        WeatherInfo(
          temperature: '$temperature°',
        ),
      ],
    );
  }

  Widget _buildTemperatureRing() {
    // Tentukan status suhu untuk label
    String suhuLabel;
    Color suhuColor;
    double temp = double.tryParse(temperature) ?? 0;

    if (temp < 20) {
      suhuLabel = "Suhu Helm Dingin";
      suhuColor = AppColors.skyBlue;
    } else if (temp <= 28) {
      suhuLabel = "Suhu Helm Stabil";
      suhuColor = AppColors.deepBlue;
    } else if (temp <= 35) {
      suhuLabel = "Suhu Helm Hangat";
      suhuColor = AppColors.yellow;
    } else {
      suhuLabel = "Suhu Helm Panas";
      suhuColor = AppColors.red;
    }

    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lingkaran luar gradasi lembut
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.skyBlue.withValues(alpha: 0.25),
                  AppColors.skyBlue.withValues(alpha: 0.02),
                  Colors.transparent,
                ],
                stops: const [0.4, 0.8, 1.0],
              ),
            ),
          ),

          // Teks Suhu Internal Helm
          Positioned(
            top: 10,
            child: Container(
              width: 220,
              height: 220,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 32, 184, 255)
                      .withValues(alpha: 0.13),
                  width: 3,
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 53, 188, 255)
                        .withValues(alpha: 0.04),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/Snowflake.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        temperature,
                        style: GoogleFonts.inter(
                          fontSize: 64,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                          height: 1.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          "°C",
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Kelembapan ",
                        style: GoogleFonts.inter(
                          color: AppColors.darkGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "$humidity%",
                        style: GoogleFonts.inter(
                          color: AppColors.deepBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Kipas ",
                        style: GoogleFonts.inter(
                          color: AppColors.darkGrey,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        fanIsOn
                            ? Icons.toggle_on_rounded
                            : Icons.toggle_off_rounded,
                        color: fanIsOn ? AppColors.green : AppColors.darkGrey,
                        size: 18,
                      ),
                      Text(
                        fanIsOn ? "ON" : "OFF",
                        style: GoogleFonts.inter(
                          color:
                              fanIsOn ? AppColors.green : AppColors.darkGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    suhuLabel,
                    style: GoogleFonts.inter(
                      color: suhuColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Gambar Komponen Helm
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/helm.png',
                    height: 218,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 0),
                  Image.asset(
                    'assets/ellipse.png',
                    width: 400,
                    height: 40,
                    fit: BoxFit.fill,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.chevron_left, size: 14, color: AppColors.darkGrey),
              SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 14, color: AppColors.darkGrey),
            ],
          ),
        ),
      ],
    );
  }
}
