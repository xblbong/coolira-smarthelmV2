import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const CooliraApp());
}

class AppColors {
  static const Color white = Colors.white;
  static const Color background = Color(0xFFF4FAFC);
  static const Color slateDark = Color(0xFF1E293B);
  static const Color slateLight = Color(0xFF64748B);
  
  // Custom cool themes
  static const Color bluePrimary = Color(0xFF2879C9);
  static const Color blueAccent = Color(0xFF3BA1E6);
  static const Color blueLightBg = Color(0xFFEEF7FC);
  static const Color blueLightBorder = Color(0xFFCBE5F7);
  
  static const Color tealPrimary = Color(0xFF10B981);
  static const Color tealLightBg = Color(0xFFECFDF5);
  static const Color tealLightBorder = Color(0xFFD1FAE5);
  
  static const Color greenStatus = Color(0xFF1ECF36);
  static const Color redAlert = Color(0xFFFF383C);
}

class CooliraApp extends StatelessWidget {
  const CooliraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coolora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isPowerOn = true;
  String _activeMode = "Auto"; // "Normal", "Turbo", "Auto", "Manual"
  int _batteryLevel = 85;
  int _helmetTemp = 25;
  int _currentTab = 0; // 0: Home, 1: Helmet, 2: Profile

  void _onPowerToggled() {
    setState(() {
      _isPowerOn = !_isPowerOn;
    });
  }

  void _onModeChanged(String mode) {
    setState(() {
      _activeMode = mode;
      // Dynamically simulate temperature and battery level based on selected mode
      if (mode == "Turbo") {
        _helmetTemp = 20;
        _batteryLevel = 78;
      } else if (mode == "Normal") {
        _helmetTemp = 23;
        _batteryLevel = 82;
      } else if (mode == "Auto") {
        _helmetTemp = 25;
        _batteryLevel = 85;
      } else if (mode == "Manual") {
        _helmetTemp = 27;
        _batteryLevel = 88;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Top wave/curve background
          const TopBackgroundWave(),

          // 2. Main content scroll area
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildMainHelmetCard(),
                  const SizedBox(height: 20),
                  _buildControlPanel(),
                  const SizedBox(height: 20),
                  _buildRideHistoryCard(),
                  const SizedBox(height: 130), // Spacing for bottom nav bar
                ],
              ),
            ),
          ),

          // 3. Custom Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavigationBar(
              currentTab: _currentTab,
              onTabChanged: (tabIndex) {
                setState(() {
                  _currentTab = tabIndex;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- HEADER SECTION ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?u=rayyan',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selamat Pagi, Rayyan 🌤️",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.slateDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Nikmati perjalanan lebih sejuk hari ini!",
                  style: GoogleFonts.inter(
                    color: AppColors.slateLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Notification Badge Container
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.slateDark,
                size: 24,
              ),
              Positioned(
                top: 13,
                right: 13,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.redAlert,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- MAIN HELMET CARD ---
  Widget _buildMainHelmetCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Info Row (ID, Status, Battery, Weather Capsule)
          Row(
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
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.sports_motorsports_rounded,
                          color: AppColors.slateDark,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "CR-001",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: AppColors.slateDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: _isPowerOn ? AppColors.greenStatus : AppColors.slateLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isPowerOn ? "Terhubung" : "Terputus",
                        style: GoogleFonts.inter(
                          color: _isPowerOn ? AppColors.greenStatus : AppColors.slateLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildBatteryIndicator(_batteryLevel),
                ],
              ),
              _buildWeatherCapsule(),
            ],
          ),

          const SizedBox(height: 10),

          // Central Radial Ring + Helmet Visual
          _buildHelmetTempGauge(),

          const SizedBox(height: 12),

          // Bottom right link
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                // Interactive trigger for usage manual
              },
              child: Text(
                "Cara Penggunaan",
                style: GoogleFonts.poppins(
                  color: AppColors.slateLight,
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Battery widget matching screenshot
  Widget _buildBatteryIndicator(int level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F9FE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF78CFED).withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 20,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: AppColors.blueAccent,
                    width: 1.2,
                  ),
                ),
              ),
              Positioned(
                left: 2,
                child: Container(
                  width: 12 * (level / 100),
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.blueAccent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              // Positive terminal
              Positioned(
                right: -2,
                top: 3,
                child: Container(
                  width: 1.2,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.blueAccent,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(1),
                      bottomRight: Radius.circular(1),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          Text(
            "$level%",
            style: GoogleFonts.inter(
              color: AppColors.blueAccent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Weather capsule widget matching screenshot
  Widget _buildWeatherCapsule() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      width: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFCCF0FA).withValues(alpha: 0.5),
            AppColors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF78CFED).withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF78CFED).withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "12:21",
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.slateDark,
            ),
          ),
          const SizedBox(height: 6),
          Image.asset(
            'assets/icons/sun.png',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.wb_sunny_outlined,
              color: Colors.amber,
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "35°",
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.bluePrimary,
            ),
          ),
        ],
      ),
    );
  }

  // Radial Temp Gauge Widget with Overlaying Helmet
  Widget _buildHelmetTempGauge() {
    return SizedBox(
      height: 380,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 1. Radial Glow Background
          Positioned(
            top: 15,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF78CFED).withValues(alpha: 0.35),
                    const Color(0xFF78CFED).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // 2. White Temperature Gauge Card
          Positioned(
            top: 25,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF78CFED).withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.ac_unit_rounded,
                    color: _isPowerOn ? AppColors.blueAccent : AppColors.slateLight,
                    size: 26,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPowerOn ? "$_helmetTemp" : "--",
                        style: GoogleFonts.inter(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slateDark,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        "°C",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slateDark,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      text: "Suhu Helm ",
                      style: GoogleFonts.inter(
                        color: AppColors.slateLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: _isPowerOn ? "Stabil" : "Nonaktif",
                          style: TextStyle(
                            color: _isPowerOn ? AppColors.blueAccent : AppColors.slateLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Overlapping Helmet Image
          Positioned(
            top: 155,
            height: 180,
            child: Image.asset(
              'assets/images/helm.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/helmet.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.sports_motorsports_rounded,
                  size: 140,
                  color: AppColors.slateLight,
                ),
              ),
            ),
          ),

          // 4. Ellipse Shadow under the Helmet
          Positioned(
            top: 310,
            width: 220,
            height: 50,
            child: Image.asset(
              'assets/ellipse.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(),
            ),
          ),
        ],
      ),
    );
  }

  // --- CONTROL PANEL ROW ---
  Widget _buildControlPanel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildModeButton(
          icon: Icons.ac_unit_rounded,
          label: "Normal",
          isActive: _isPowerOn && _activeMode == "Normal",
          onTap: () {
            if (_isPowerOn) _onModeChanged("Normal");
          },
          activeColor: AppColors.blueAccent,
          activeBg: AppColors.blueLightBg,
          activeBorder: AppColors.blueLightBorder,
        ),
        _buildModeButton(
          icon: Icons.air_rounded,
          label: "Turbo",
          isActive: _isPowerOn && _activeMode == "Turbo",
          onTap: () {
            if (_isPowerOn) _onModeChanged("Turbo");
          },
          activeColor: AppColors.blueAccent,
          activeBg: AppColors.blueLightBg,
          activeBorder: AppColors.blueLightBorder,
        ),
        _buildPowerButton(
          isOn: _isPowerOn,
          onTap: _onPowerToggled,
        ),
        _buildModeButton(
          icon: Icons.auto_awesome_rounded,
          label: "Auto",
          isActive: _isPowerOn && _activeMode == "Auto",
          onTap: () {
            if (_isPowerOn) _onModeChanged("Auto");
          },
          activeColor: AppColors.tealPrimary,
          activeBg: AppColors.tealLightBg,
          activeBorder: AppColors.tealLightBorder,
        ),
        _buildModeButton(
          icon: Icons.waves_rounded,
          label: "Manual",
          isActive: _isPowerOn && _activeMode == "Manual",
          onTap: () {
            if (_isPowerOn) _onModeChanged("Manual");
          },
          activeColor: AppColors.tealPrimary,
          activeBg: AppColors.tealLightBg,
          activeBorder: AppColors.tealLightBorder,
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color activeColor,
    required Color activeBg,
    required Color activeBorder,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isActive ? activeBg : AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isActive ? activeBorder : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isActive ? activeColor : const Color(0xFFA1A1AA),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.slateDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerButton({required bool isOn, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: (isOn ? AppColors.blueAccent : Colors.black).withValues(alpha: isOn ? 0.25 : 0.08),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isOn
                  ? const LinearGradient(
                      colors: [Color(0xFF6BE1E6), Color(0xFF2879C9)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
            ),
            child: const Icon(
              Icons.power_settings_new_rounded,
              color: AppColors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  // --- RIDE HISTORY CARD ---
  Widget _buildRideHistoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Riwayat Berkendara",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.slateDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHistoryItem(
                  value: "82%",
                  title: "Energi Tersimpan",
                  subtitle: "dari Solar Panel",
                  imagePath: 'assets/images/sun-2.png',
                ),
              ),
              Container(
                height: 50,
                width: 1,
                color: const Color(0xFFE5E7EB),
              ),
              Expanded(
                child: _buildHistoryItem(
                  value: "2j 3mnt",
                  title: "Total Waktu Pakai",
                  subtitle: "Pendingin/Daya",
                  imagePath: 'assets/images/suryapanel.png',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required String value,
    required String title,
    required String subtitle,
    required String imagePath,
  }) {
    return Row(
      children: [
        const SizedBox(width: 8),
        ClipOval(
          child: Image.asset(
            imagePath,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 48,
              height: 48,
              color: AppColors.blueLightBg,
              child: const Icon(Icons.wb_sunny_rounded, color: AppColors.blueAccent, size: 24),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppColors.bluePrimary,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateDark,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: AppColors.slateLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- WAVY TOP DECORATION PAINTERS ---
class TopBackgroundWave extends StatelessWidget {
  const TopBackgroundWave({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 260,
      child: CustomPaint(
        painter: TopBackgroundPainter(),
      ),
    );
  }
}

class TopBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Wave Layer 1
    final paint1 = Paint()
      ..color = const Color(0xFFE3F6FC).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
      
    final path1 = Path();
    path1.moveTo(0, 0);
    path1.lineTo(0, size.height * 0.7);
    path1.quadraticBezierTo(
      size.width * 0.3, size.height * 0.95,
      size.width * 0.6, size.height * 0.78,
    );
    path1.quadraticBezierTo(
      size.width * 0.85, size.height * 0.66,
      size.width, size.height * 0.85,
    );
    path1.lineTo(size.width, 0);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Wave Layer 2 (Slightly higher, different opacity)
    final paint2 = Paint()
      ..color = const Color(0xFFD3EEF8).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, 0);
    path2.lineTo(0, size.height * 0.55);
    path2.quadraticBezierTo(
      size.width * 0.25, size.height * 0.78,
      size.width * 0.52, size.height * 0.68,
    );
    path2.quadraticBezierTo(
      size.width * 0.78, size.height * 0.58,
      size.width, size.height * 0.75,
    );
    path2.lineTo(size.width, 0);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- CUSTOM CURVED BOTTOM NAVIGATION ---
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentTab;
  final ValueChanged<int> onTabChanged;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 95,
      width: screenWidth,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Curved background
          CustomPaint(
            size: Size(screenWidth, 95),
            painter: BottomNavPainter(),
          ),

          // Icon buttons row
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 75,
            child: Row(
              children: [
                // Left Tab (Home) with Spotlight Glow
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTabChanged(0),
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        if (currentTab == 0)
                          Positioned(
                            top: -10,
                            child: ClipPath(
                              clipper: SpotlightClipper(),
                              child: Container(
                                width: 90,
                                height: 85,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color(0xFF78CFED).withValues(alpha: 0.35),
                                      const Color(0xFF78CFED).withValues(alpha: 0.01),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Icon(
                          Icons.home_filled,
                          color: currentTab == 0 ? AppColors.bluePrimary : const Color(0xFFA1A1AA),
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ),

                // Spacer for the center FAB
                const SizedBox(width: 80),

                // Right Tab (Profile)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTabChanged(2),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: currentTab == 2 ? AppColors.bluePrimary : const Color(0xFFA1A1AA),
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Action Button
          Positioned(
            bottom: 25,
            child: GestureDetector(
              onTap: () => onTabChanged(1),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6BE1E6), Color(0xFF2879C9)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      border: Border.all(color: AppColors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2879C9).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.sports_motorsports_rounded,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3BA1E6),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          color: AppColors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.04)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Curved top left
    path.moveTo(0, 30);
    path.quadraticBezierTo(0, 0, 30, 0);

    // Line to dome start
    final centerX = width / 2;
    const domeWidth = 110.0;
    const domeHeight = 32.0;
    final domeStart = centerX - domeWidth / 2;
    final domeEnd = centerX + domeWidth / 2;

    path.lineTo(domeStart, 0);
    path.cubicTo(
      domeStart + 22, 0,
      centerX - 28, -domeHeight,
      centerX, -domeHeight,
    );
    path.cubicTo(
      centerX + 28, -domeHeight,
      domeEnd - 22, 0,
      domeEnd, 0,
    );

    // Line to top right
    path.lineTo(width - 30, 0);
    path.quadraticBezierTo(width, 0, width, 30);

    // Close boundaries
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SpotlightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final topWidth = 28.0;
    final bottomWidth = 75.0;
    final centerX = size.width / 2;

    path.moveTo(centerX - topWidth / 2, 0);
    path.lineTo(centerX + topWidth / 2, 0);
    path.lineTo(centerX + bottomWidth / 2, size.height);
    path.lineTo(centerX - bottomWidth / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
