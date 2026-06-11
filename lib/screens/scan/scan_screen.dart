import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/helmet_provider.dart';
import '../dashboard/dashboard_screen.dart';

/// Halaman untuk scan dan menghubungkan ke ESP32 via BLE.
///
/// Alur:
/// 1. User tap "Scan" → app mencari device BLE di sekitar
/// 2. User tap device yang ditemukan → app menghubungkan
/// 3. Setelah terhubung → navigasi ke DashboardScreen
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-scan saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScan();
    });
  }

  void _startScan() {
    final provider = context.read<HelmetProvider>();
    provider.startScan();
  }

  Future<void> _connectToDevice(dynamic scanResult) async {
    final provider = context.read<HelmetProvider>();

    // Tampilkan dialog connecting
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Menghubungkan...'),
              ],
            ),
          ),
        ),
      ),
    );

    await provider.connectToDevice(scanResult.device);

    if (!mounted) return;

    // Tutup dialog
    Navigator.of(context).pop();

    if (provider.isConnected) {
      // Berhasil! Navigasi ke dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      // Gagal, tampilkan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage.isEmpty
              ? 'Gagal terhubung ke device'
              : provider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFC),
      body: Stack(
        children: [
          // Gradient header
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
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Illustration & status
                _buildStatusSection(),

                const SizedBox(height: 16),

                // Scan button
                _buildScanButton(),

                const SizedBox(height: 16),

                // Device list
                Expanded(child: _buildDeviceList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
          Expanded(
            child: Text(
              'Hubungkan Perangkat',
              style: GoogleFonts.inter(
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

  Widget _buildStatusSection() {
    return Consumer<HelmetProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Bluetooth icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  provider.isScanning
                      ? Icons.bluetooth_searching_rounded
                      : Icons.bluetooth_rounded,
                  color: AppColors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                provider.isScanning
                    ? 'Mencari perangkat...'
                    : 'Tekan Scan untuk mencari perangkat',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              if (provider.errorMessage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.red.shade200,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildScanButton() {
    return Consumer<HelmetProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: provider.isScanning
                  ? () => provider.stopScan()
                  : _startScan,
              icon: Icon(
                provider.isScanning
                    ? Icons.stop_rounded
                    : Icons.bluetooth_searching_rounded,
              ),
              label: Text(
                provider.isScanning ? 'Berhenti Scan' : 'Scan Perangkat',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceList() {
    return Consumer<HelmetProvider>(
      builder: (context, provider, _) {
        if (provider.isScanning && provider.scanResults.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Mencari perangkat...'),
              ],
            ),
          );
        }

        if (provider.scanResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bluetooth_disabled_rounded,
                  size: 64,
                  color: AppColors.darkGrey.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum menemukan perangkat',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pastikan ESP32 sudah menyala dan\nberada dalam jangkauan Bluetooth',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.darkGrey.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: provider.scanResults.length,
          itemBuilder: (context, index) {
            final result = provider.scanResults[index];
            final deviceName = result.device.platformName.isNotEmpty
                ? result.device.platformName
                : 'Unknown Device';
            final deviceId = result.device.remoteId.toString();
            final rssi = result.rssi;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.skyBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.bluetooth_rounded,
                    color: AppColors.deepBlue,
                    size: 24,
                  ),
                ),
                title: Text(
                  deviceName,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  deviceId,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.darkGrey,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getRssiIcon(rssi),
                      size: 18,
                      color: _getRssiColor(rssi),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$rssi dBm',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
                onTap: () => _connectToDevice(result),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getRssiIcon(int rssi) {
    if (rssi > -60) return Icons.signal_cellular_4_bar_rounded;
    if (rssi > -80) return Icons.signal_cellular_alt_2_bar_rounded;
    return Icons.signal_cellular_alt_1_bar_rounded;
  }

  Color _getRssiColor(int rssi) {
    if (rssi > -60) return AppColors.green;
    if (rssi > -80) return AppColors.yellow;
    return AppColors.red;
  }
}
