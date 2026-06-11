import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/helmet_provider.dart';
import '../../widgets/header_section.dart';
import '../../widgets/helmet_card.dart';
import '../../widgets/control_panel.dart';
import '../../widgets/history_card.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../scan/scan_screen.dart';

/// Dashboard utama aplikasi Coolira
///
/// Menampilkan data sensor real-time dari ESP32 via BLE,
/// kontrol kipas & mode, dan ringkasan riwayat perjalanan.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    // Navigasi ke halaman scan jika tap icon profile (index 2)
    // dan tidak sedang terhubung
    if (index == 2) {
      final provider = context.read<HelmetProvider>();
      if (!provider.isConnected) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScanScreen()),
        );
      }
    }
  }

  void _onModeChanged(String mode) {
    final provider = context.read<HelmetProvider>();
    provider.setMode(mode);
  }

  void _onPowerPressed() {
    final provider = context.read<HelmetProvider>();
    provider.toggleFan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          _buildBackgroundGradient(),

          // Main scroll content
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer<HelmetProvider>(
                builder: (context, provider, _) {
                  return Column(
                    children: [
                      const SizedBox(height: 15),
                      const HeaderSection(),
                      const SizedBox(height: 20),

                      // Helm Card dengan data real-time
                      HelmetCard(
                        deviceId: provider.deviceName.isNotEmpty
                            ? provider.deviceName
                            : 'CooliraHelmet',
                        temperature: provider.temperature.toStringAsFixed(1),
                        humidity: provider.humidity.toStringAsFixed(1),
                        status: provider.isConnected
                            ? 'Terhubung'
                            : 'Terputus',
                        isConnected: provider.isConnected,
                        batteryPercent: provider.batteryLevel,
                        fanIsOn: provider.fanIsOn,
                        onTapConnection: () {
                          // Navigasi ke halaman Scan BLE
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ScanScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Control Panel
                      ControlPanel(
                        activeMode: provider.currentMode,
                        onModeChanged: _onModeChanged,
                        onPowerPressed: _onPowerPressed,
                      ),
                      const SizedBox(height: 20),

                      // History Card
                      HistoryCard(
                        trips: provider.getAllTrips(),
                      ),
                      const SizedBox(height: 140),
                    ],
                  );
                },
              ),
            ),
          ),

          // Bottom navigation
          CustomBottomNav(
            currentIndex: _currentNavIndex,
            onTap: _onNavTap,
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.skyBlue.withValues(alpha: 0.25),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}
