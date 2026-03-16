import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/device_scanner_dialog.dart';
import '../services/bluetooth_service.dart';
import 'connection_status_screen.dart';

class OBDConnectingScreen extends StatefulWidget {
  final ScannedDevice device;

  const OBDConnectingScreen({super.key, required this.device});

  @override
  State<OBDConnectingScreen> createState() => _OBDConnectingScreenState();
}

enum _ConnectionStep { initializing, searching, handshaking, complete }

enum _StepStatus { pending, inProgress, done }

class _OBDConnectingScreenState extends State<OBDConnectingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  _ConnectionStep _currentStep = _ConnectionStep.initializing;
  double _progress = 0.0;
  bool _cancelled = false;

  final _btService = OBDBluetoothService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _runConnectionSequence();
  }

  @override
  void dispose() {
    _cancelled = true;
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _runConnectionSequence() async {
    // Step 1: Initializing – check permissions + Bluetooth state
    if (!mounted) return;
    setState(() {
      _currentStep = _ConnectionStep.initializing;
      _progress = 0.1;
    });

    final hasPermissions = await _btService.requestPermissions();
    if (_cancelled || !mounted) return;

    if (!hasPermissions) {
      _navigateToResult(false);
      return;
    }

    await Future.delayed(const Duration(milliseconds: 700));
    if (_cancelled || !mounted) return;

    setState(() {
      _currentStep = _ConnectionStep.searching;
      _progress = 0.38;
    });

    // Step 2: Searching – attempt actual connection
    await Future.delayed(const Duration(milliseconds: 500));
    if (_cancelled || !mounted) return;

    final connected = await _btService.connect(widget.device);
    if (_cancelled || !mounted) return;

    if (!connected) {
      _navigateToResult(false);
      return;
    }

    setState(() {
      _currentStep = _ConnectionStep.handshaking;
      _progress = 0.72;
    });

    // Step 3: Handshaking – brief delay for OBD protocol init
    await Future.delayed(const Duration(milliseconds: 1200));
    if (_cancelled || !mounted) return;

    setState(() {
      _currentStep = _ConnectionStep.complete;
      _progress = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (_cancelled || !mounted) return;

    _navigateToResult(true);
  }

  void _navigateToResult(bool isSuccess) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ConnectionStatusScreen(
          isSuccess: isSuccess,
          device: widget.device,
        ),
      ),
    );
  }

  String get _signalText {
    final rssi = widget.device.signalStrength ?? -70;
    if (rssi > -55) return 'GOOD';
    if (rssi > -65) return 'MEDIUM';
    return 'WEAK';
  }

  _StepStatus _statusOf(_ConnectionStep step) {
    if (_currentStep.index > step.index) return _StepStatus.done;
    if (_currentStep.index == step.index) return _StepStatus.inProgress;
    return _StepStatus.pending;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepSpace,
      body: SafeArea(
        child: Column(
          children: [
            // Header bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _cancelled = true;
                      _btService.disconnect();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.charcoal,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.directions_car,
                          color: AppTheme.neonBlue, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'REVORA',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated icon
                    _buildPulsingIcon()
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(
                            duration: 400.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 36),

                    // Title
                    Text(
                      'Connecting to Adapter',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(delay: 150.ms),

                    const SizedBox(height: 10),

                    Text(
                      'Please wait while Revora connects to\nyour vehicle\'s onboard diagnostic system.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 250.ms),

                    const SizedBox(height: 36),

                    // Steps checklist
                    _buildStepsList()
                        .animate()
                        .fadeIn(delay: 350.ms)
                        .slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 32),

                    // Progress bar
                    _buildProgressBar()
                        .animate()
                        .fadeIn(delay: 450.ms),

                    const SizedBox(height: 36),

                    // Cancel button
                    GestureDetector(
                      onTap: () {
                        _cancelled = true;
                        _btService.disconnect();
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.charcoal,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppTheme.glassBorder, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            'CANCEL CONNECTION',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms),

                    const SizedBox(height: 16),

                    Text(
                      'SYSTEM VERSION 2.4.0-REV',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingIcon() {
    final isBluetooth = widget.device.type == ScanType.bluetooth;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return SizedBox(
          width: 170,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.neonBlue.withValues(
                        alpha: 0.12 + 0.12 * _pulseController.value),
                    width: 2,
                  ),
                ),
              ),

              // Middle ring
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.neonBlue.withValues(
                        alpha: 0.22 +
                            0.18 * (1 - _pulseController.value)),
                    width: 2,
                  ),
                ),
              ),

              // Center
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.charcoal,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonBlue.withValues(
                          alpha: 0.28 +
                              0.16 * _pulseController.value),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  isBluetooth
                      ? Icons.bluetooth_searching
                      : Icons.wifi_find,
                  color: AppTheme.neonBlue,
                  size: 38,
                ),
              ),

              // SCANNING badge
              Positioned(
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.neonBlue.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.neonBlue.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.neonBlue,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonBlue
                                  .withValues(alpha: 0.6),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'SCANNING',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.neonBlue,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepRow(
            'Initializing Bluetooth Stack',
            _statusOf(_ConnectionStep.initializing)),
        const SizedBox(height: 14),
        _buildStepRow(
            'Searching for OBD-II Adapter',
            _statusOf(_ConnectionStep.searching)),
        const SizedBox(height: 14),
        _buildStepRow(
            'Handshaking with ECU',
            _statusOf(_ConnectionStep.handshaking)),
      ],
    );
  }

  Widget _buildStepRow(String label, _StepStatus status) {
    Widget icon;
    Color textColor;

    switch (status) {
      case _StepStatus.done:
        icon = const Icon(Icons.check_circle,
            color: AppTheme.neonBlue, size: 22);
        textColor = Colors.white;
        break;
      case _StepStatus.inProgress:
        icon = AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) => Icon(
            Icons.sync,
            color: AppTheme.neonBlue
                .withValues(alpha: 0.6 + 0.4 * _pulseController.value),
            size: 22,
          ),
        );
        textColor = Colors.white;
        break;
      case _StepStatus.pending:
        icon = const Icon(Icons.radio_button_unchecked,
            color: AppTheme.textMuted, size: 22);
        textColor = AppTheme.textMuted;
        break;
    }

    return Row(
      children: [
        icon,
        const SizedBox(width: 14),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 4,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: AppTheme.charcoal,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  height: 4,
                  width: constraints.maxWidth * _progress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppTheme.neonBlue, AppTheme.neonCyan]),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonBlue.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SIGNAL STRENGTH: $_signalText',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                color: AppTheme.textMuted,
                letterSpacing: 1,
              ),
            ),
            Text(
              '${(_progress * 100).toInt()}% COMPLETE',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                color: AppTheme.textMuted,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
