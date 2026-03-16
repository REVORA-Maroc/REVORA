import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/device_scanner_dialog.dart';

class ConnectionStatusScreen extends StatefulWidget {
  final bool isSuccess;
  final ScannedDevice device;

  const ConnectionStatusScreen({
    super.key,
    required this.isSuccess,
    required this.device,
  });

  @override
  State<ConnectionStatusScreen> createState() =>
      _ConnectionStatusScreenState();
}

class _ConnectionStatusScreenState extends State<ConnectionStatusScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  final List<bool> _checklist = [false, false, false];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _tryAgain() {
    Navigator.pop(context); // Back to connecting → scanning
  }

  void _changeMethod() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepSpace,
      appBar: AppBar(
        backgroundColor: AppTheme.deepSpace,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          widget.isSuccess ? 'Connection Status' : 'Revora',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: widget.isSuccess
            ? null
            : [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.error_outline,
                        color: Colors.red, size: 20),
                  ),
                ),
              ],
      ),
      body: widget.isSuccess ? _buildSuccessBody() : _buildFailedBody(),
    );
  }

  // ─── SUCCESS ─────────────────────────────────────────────────────────────

  Widget _buildSuccessBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 36),

          // Animated success icon
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) => Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.charcoal,
                border: Border.all(
                  color: AppTheme.neonBlue.withValues(
                      alpha: 0.2 + 0.2 * _glowController.value),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonBlue.withValues(
                        alpha: 0.2 + 0.18 * _glowController.value),
                    blurRadius: 32,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppTheme.neonBlue,
                size: 58,
              ),
            ),
          )
              .animate()
              .scale(duration: 450.ms, curve: Curves.elasticOut),

          const SizedBox(height: 28),

          Text(
            'Vehicle Connected\nSuccessfully',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

          const SizedBox(height: 12),

          Text(
            'Your adapter is connected. You can now\naccess diagnostics, dashboard, and live data.',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 32),

          // Go to Home
          GestureDetector(
            onTap: _goToHome,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.neonBlue, AppTheme.neonCyan]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonBlue.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Go to Home',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 28),

          // Section title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Vehicle Summary',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Vehicle card
          _buildVehicleCard()
              .animate()
              .fadeIn(delay: 500.ms)
              .slideY(begin: 0.15, end: 0),

          const SizedBox(height: 12),

          // Status tiles row
          Row(
            children: [
              Expanded(
                child: _buildStatusTile(
                  label: 'Connection',
                  value: 'Active',
                  valueColor: AppTheme.neonBlue,
                  icon: Icons.sensors,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusTile(
                  label: 'Signal',
                  value: 'Excellent',
                  valueColor: AppTheme.electricGreen,
                  icon: Icons.signal_cellular_alt,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 600.ms),

          const SizedBox(height: 12),

          // Adapter tile
          _buildAdapterTile()
              .animate()
              .fadeIn(delay: 700.ms),

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildVehicleCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.charcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2023 Revora Model S',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Plaid Performance Edition',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.neonBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'VIN: 1HGCM82635A00212',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.neonBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.neonBlue.withValues(alpha: 0.3),
                      width: 1),
                ),
                child: const Icon(Icons.electric_car,
                    color: AppTheme.neonBlue, size: 26),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppTheme.glassBorder, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.battery_charging_full,
                      color: AppTheme.electricGreen, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '88% Charge',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'View Details >',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.neonBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile({
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.charcoal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.glassBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.textMuted, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdapterTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.charcoal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.glassBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.neonBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.settings_input_component_outlined,
                color: AppTheme.neonBlue, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OBD-II Adapter',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.device.name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.electricGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.electricGreen,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.electricGreen
                            .withValues(alpha: 0.6),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'LIVE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.electricGreen,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── FAILURE ─────────────────────────────────────────────────────────────

  Widget _buildFailedBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 36),

          // Failure icon
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.charcoal,
              border:
                  Border.all(color: AppTheme.glassBorder, width: 1.5),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.wifi_off,
                    color: AppTheme.textMuted, size: 56),
                Positioned(
                  bottom: 16,
                  child: Container(
                    height: 3,
                    width: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppTheme.neonBlue, AppTheme.neonCyan]),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .scale(duration: 400.ms, curve: Curves.easeOutBack),

          const SizedBox(height: 28),

          Text(
            'Connection Failed',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 12),

          Text(
            'We couldn\'t connect to your OBD2\nadapter. Please check your device and\ntry again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 32),

          // Troubleshooting section
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'TROUBLESHOOTING',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMuted,
                letterSpacing: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(color: AppTheme.glassBorder, height: 1),

          _buildTroubleshootItem(
            index: 0,
            title: 'Power on adapter',
            subtitle: 'Ensure the device is plugged in and active',
          ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),

          _buildTroubleshootItem(
            index: 1,
            title: 'Stay close',
            subtitle: 'Keep your phone within 3 feet of the dashboard',
          ).animate().fadeIn(delay: 480.ms).slideX(begin: 0.1, end: 0),

          _buildTroubleshootItem(
            index: 2,
            title: 'Check BT/Wi-Fi',
            subtitle: 'Confirm your wireless connections are enabled',
          ).animate().fadeIn(delay: 560.ms).slideX(begin: 0.1, end: 0),

          const SizedBox(height: 32),

          // Try Again button
          GestureDetector(
            onTap: _tryAgain,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.neonBlue, AppTheme.neonCyan]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonBlue.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Try Again',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.refresh, color: Colors.black, size: 18),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 640.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 12),

          // Change Method button
          GestureDetector(
            onTap: _changeMethod,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.charcoal,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.glassBorder, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Change Method',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.tune, color: Colors.white, size: 18),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 720.ms),

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildTroubleshootItem({
    required int index,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _checklist[index] = !_checklist[index]),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _checklist[index]
                        ? AppTheme.neonBlue
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _checklist[index]
                          ? AppTheme.neonBlue
                          : AppTheme.glassBorder,
                      width: 1.5,
                    ),
                  ),
                  child: _checklist[index]
                      ? const Icon(Icons.check,
                          color: Colors.black, size: 14)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(color: AppTheme.glassBorder, height: 1),
      ],
    );
  }
}
