import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

/// Header section dengan avatar, greeting, dan notifikasi
class HeaderSection extends StatelessWidget {
  final String userName;
  final String greeting;
  final String subtitle;
  final String avatarUrl;
  final int notificationCount;

  const HeaderSection({
    super.key,
    this.userName = 'Rayyan',
    this.greeting = 'Selamat Pagi',
    this.subtitle = 'Nikmati perjalanan lebih sejuk hari ini!',
    this.avatarUrl = 'https://i.pravatar.cc/150?u=rayyan',
    this.notificationCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar & Greeting
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
              child: CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(avatarUrl),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "$greeting, $userName",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text("🌤️", style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: AppColors.darkGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Notification Badge
        _buildNotificationBadge(),
      ],
    );
  }

  Widget _buildNotificationBadge() {
    return Container(
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
            color: AppColors.black,
            size: 24,
          ),
          if (notificationCount > 0)
            Positioned(
              top: 12,
              right: 13,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
