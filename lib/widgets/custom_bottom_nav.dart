import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Custom bottom navigation bar dengan tombol tengah menggantung
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 25,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Home Icon
              GestureDetector(
                onTap: () => onTap?.call(0),
                child: Icon(
                  Icons.home_filled,
                  color: currentIndex == 0
                      ? AppColors.deepBlue
                      : AppColors.darkGrey,
                  size: 28,
                ),
              ),

              // Center Button (Motorcycle)
              Transform.translate(
                offset: const Offset(0, -10),
                child: GestureDetector(
                  onTap: () => onTap?.call(1),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.accentGrad,
                      border: Border.all(color: AppColors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepBlue.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.motorcycle_rounded,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),

              // Profile Icon
              GestureDetector(
                onTap: () => onTap?.call(2),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: currentIndex == 2
                      ? AppColors.deepBlue
                      : AppColors.darkGrey,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
