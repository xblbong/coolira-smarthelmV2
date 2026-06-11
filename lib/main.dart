import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/helmet_provider.dart';
import 'services/trip_service.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  // Pastikan Flutter siap sebelum inisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive untuk penyimpanan data lokal
  await TripService.init();

  runApp(const CooliraApp());
}

/// Entry point aplikasi Coolira
class CooliraApp extends StatelessWidget {
  const CooliraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HelmetProvider(),
      child: MaterialApp(
        title: 'Coolira',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.interTextTheme(),
          scaffoldBackgroundColor: const Color(0xFFF4FAFC),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF78CFED),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
