import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/device_scanner_dialog.dart';
import '../services/bluetooth_service.dart';
import 'obd_connecting_screen.dart';

class BluetoothConnectionScreen extends StatefulWidget {
  const BluetoothConnectionScreen({super.key});

  @override
  State<BluetoothConnectionScreen> createState() =>
      _BluetoothConnectionScreenState();
}

class _BluetoothConnectionScreenState extends State<BluetoothConnectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;

  bool _isScanning = true;
  List<ScannedDevice> _devices = [];

  final _btService = OBDBluetoothService();
  StreamSubscription<List<ScannedDevice>>? _devicesSubscription;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _startScanning();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    _devicesSubscription?.cancel();
    _btService.stopScan();
    super.dispose();
  }

  Future<void> _startScanning() async {
    if (!mounted) return;
    setState(() {
      _isScanning = true;
      _devices = [];
    });

    _devicesSubscription?.cancel();
    _devicesSubscription = _btService.devicesStream.listen((devices) {
      if (!mounted) return;
      setState(() => _devices = devices);
    });

    final hasPermissions = await _btService.requestPermissions();
    if (!mounted) return;

    if (!hasPermissions) {
      setState(() => _isScanning = false);
      _showPermissionError();
      return;
    }

    await _btService.startScan(timeout: const Duration(seconds: 12));
    if (!mounted) return;

    await Future.delayed(const Duration(seconds: 12));
    if (mounted) setState(() => _isScanning = false);
  }

  void _showPermissionError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bluetooth permissions are required to scan for devices.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  Future<void> _connectToDevice(ScannedDevice device) async {
    await _btService.stopScan();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OBDConnectingScreen(device: device),
      ),
    );
  }

  String _signalLabel(int? rssi) {
    if (rssi == null) return 'Unknown';
    if (rssi > -55) return 'Strong signal';
    if (rssi > -65) return 'Medium signal';
    return 'Weak signal';
  }

  int _signalBars(int? rssi) {
    if (rssi == null) return 1;
    if (rssi > -55) return 4;
    if (rssi > -65) return 3;
    if (rssi > -75) return 2;
    return 1;
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
          'Connect OBD2',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),

            // Animated scanning area
            Center(child: _buildScanningAnimation()),

            const SizedBox(height: 28),

            // Scanning status text
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _isScanning
                    ? Text(
                        'Scanning...',
                        key: const ValueKey('scanning'),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.neonBlue,
                        ),
                      )
                    : Text(
                        'Scan Complete',
                        key: const ValueKey('done'),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.electricGreen,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                'Keep your OBD2 adapter close and ensure Bluetooth\nis enabled on your device',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discovered Devices',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: _isScanning ? null : _startScanning,
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 15,
                        color: _isScanning
                            ? AppTheme.textMuted
                            : AppTheme.neonBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Retry',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _isScanning
                              ? AppTheme.textMuted
                              : AppTheme.neonBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Device list
            if (_devices.isEmpty && _isScanning)
              _buildEmptyScanning()
            else
              ..._devices.asMap().entries.map((entry) {
                return _buildDeviceCard(entry.value, entry.key)
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: entry.key * 120))
                    .slideY(begin: 0.15, end: 0);
              }),

            const SizedBox(height: 24),

            // Why Revora promo card
            _buildWhyRevoraCard()
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 400))
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 20),

            Center(
              child: Text(
                'Make sure your vehicle ignition is ON before connecting.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningAnimation() {
    return SizedBox(
      width: 210,
      height: 210,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _rippleController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Ripple ring
              Container(
                width: 210 * _rippleController.value,
                height: 210 * _rippleController.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.neonBlue.withValues(
                        alpha: 0.18 * (1 - _rippleController.value)),
                    width: 2,
                  ),
                ),
              ),

              // Outer ring
              Container(
                width: 168,
                height: 168,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.neonBlue.withValues(
                        alpha: 0.18 + 0.18 * _pulseController.value),
                    width: 1.5,
                  ),
                ),
              ),

              // Middle ring
              Container(
                width: 126,
                height: 126,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.neonBlue.withValues(
                        alpha: 0.28 + 0.18 * (1 - _pulseController.value)),
                    width: 1.5,
                  ),
                ),
              ),

              // Center circle
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.charcoal,
                  border: Border.all(
                    color:
                        AppTheme.neonBlue.withValues(alpha: 0.45),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonBlue.withValues(
                          alpha: 0.25 + 0.15 * _pulseController.value),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bluetooth_searching,
                  color: AppTheme.neonBlue,
                  size: 40,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyScanning() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          'Looking for nearby OBD-II devices...',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            color: AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(ScannedDevice device, int index) {
    final isPrimary = index == 0;
    final bars = _signalBars(device.signalStrength);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.charcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary
              ? AppTheme.neonBlue.withValues(alpha: 0.45)
              : AppTheme.glassBorder,
          width: 1,
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppTheme.neonBlue.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Device icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.neonBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.directions_car_outlined,
              color: AppTheme.neonBlue,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Device info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      device.name,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (isPrimary) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.neonBlue.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Found',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.neonBlue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Signal bars
                    Row(
                      children: List.generate(4, (i) {
                        return Container(
                          width: 3,
                          height: 5.0 + (i * 2.5),
                          margin: const EdgeInsets.only(right: 2),
                          decoration: BoxDecoration(
                            color: i < bars
                                ? AppTheme.neonCyan
                                : AppTheme.glassBorder,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${_signalLabel(device.signalStrength)} • ${device.address}',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Connect button
          GestureDetector(
            onTap: () => _connectToDevice(device),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isPrimary
                    ? const LinearGradient(
                        colors: [AppTheme.neonBlue, AppTheme.neonCyan])
                    : null,
                color: isPrimary ? null : AppTheme.graphite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Connect',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isPrimary ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyRevoraCard() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.charcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Car image on the right
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 160,
            child: Image.asset(
              'assets/images/car.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppTheme.midnightBlue,
              ),
            ),
          ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.charcoal,
                    AppTheme.charcoal.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Text content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Why Revora?',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.neonBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Direct integration for real-time\nengine diagnostics and\nperformance metrics.',
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
    );
  }
}
