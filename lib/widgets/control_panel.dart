import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'mode_button.dart';

/// Panel kontrol mode helm (Normal, Turbo, Power, Auto, Manual)
class ControlPanel extends StatefulWidget {
  final String activeMode;
  final Function(String)? onModeChanged;
  final VoidCallback? onPowerPressed;

  const ControlPanel({
    super.key,
    this.activeMode = 'Auto',
    this.onModeChanged,
    this.onPowerPressed,
  });

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  late String _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.activeMode;
  }

  void _onModeTap(String mode) {
    setState(() {
      _currentMode = mode;
    });
    widget.onModeChanged?.call(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ModeButton(
          icon: Icons.ac_unit_rounded,
          label: "Normal",
          isActive: _currentMode == 'Normal',
          onTap: () => _onModeTap('Normal'),
        ),
        ModeButton(
          icon: Icons.air_rounded,
          label: "Turbo",
          isActive: _currentMode == 'Turbo',
          onTap: () => _onModeTap('Turbo'),
        ),
        _buildPowerButton(),
        ModeButton(
          icon: Icons.auto_awesome_rounded,
          label: "Auto",
          isActive: _currentMode == 'Auto',
          onTap: () => _onModeTap('Auto'),
        ),
        ModeButton(
          icon: Icons.waves,
          label: "Manual",
          isActive: _currentMode == 'Manual',
          onTap: () => _onModeTap('Manual'),
        ),
      ],
    );
  }

  Widget _buildPowerButton() {
    return GestureDetector(
      onTap: widget.onPowerPressed,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.accentGrad,
          boxShadow: [
            BoxShadow(
              color: AppColors.deepBlue.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.power_settings_new_rounded,
          color: AppColors.white,
          size: 34,
        ),
      ),
    );
  }
}
