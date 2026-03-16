import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/device_scanner_dialog.dart';
import 'obd_connecting_screen.dart';

class WifiConnectionScreen extends StatefulWidget {
  const WifiConnectionScreen({super.key});

  @override
  State<WifiConnectionScreen> createState() => _WifiConnectionScreenState();
}

class _WifiConnectionScreenState extends State<WifiConnectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _dotController;

  bool _isScanning = true;
  List<ScannedDevice> _devices = [];
  ScannedDevice? _selectedDevice;
  Timer? _scanTimer;

  static const _mockDevices = [
    ('OBDII-WiFi-2938', '192.168.0.10', -38),
    ('V-Linker-F492', '192.168.0.11', -57),
  ];

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _startScanning();
  }

  @override
  void dispose() {
    _dotController.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _devices = [];
      _selectedDevice = null;
    });

    int index = 0;
    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(const Duration(milliseconds: 1100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (index < _mockDevices.length) {
        final d = _mockDevices[index];
        setState(() {
          _devices.add(ScannedDevice(
            id: 'wifi_$index',
            name: d.$1,
            address: d.$2,
            signalStrength: d.$3,
            type: ScanType.wifi,
          ));
        });
        index++;
      } else {
        timer.cancel();
        if (mounted) setState(() => _isScanning = false);
      }
    });
  }

  String _signalLabel(int? rssi) {
    if (rssi == null) return 'Unknown';
    if (rssi > -50) return 'Excellent';
    if (rssi > -65) return 'Good';
    return 'Fair';
  }

  void _connectSelected() {
    if (_selectedDevice == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OBDConnectingScreen(device: _selectedDevice!),
      ),
    );
  }

  void _showManualConnectionDialog() {
    final ipController = TextEditingController(text: '192.168.0.10');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.midnightBlue,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Manual Connection',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the IP address of your OBD2 device:',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ipController,
              style: GoogleFonts.spaceGrotesk(color: Colors.white),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: AppTheme.getFuturisticInputDecoration(
                hint: '192.168.0.10',
                prefixIcon: Icons.lan_outlined,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted),
            ),
          ),
          GestureDetector(
            onTap: () {
              final ip = ipController.text.trim();
              Navigator.pop(ctx);
              final device = ScannedDevice(
                id: 'manual',
                name: 'Manual: $ip',
                address: ip,
                signalStrength: -50,
                type: ScanType.wifi,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => OBDConnectingScreen(device: device)),
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.neonBlue, AppTheme.neonCyan]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Connect',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
          'Connect via Wi-Fi',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  Text(
                    'Connect via Wi-Fi',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 8),

                  Text(
                    'Ensure your OBD2 adapter is plugged into\nyour vehicle and its Wi-Fi signal is active.',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 100.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 20),

                  // Scanning indicator
                  if (_isScanning)
                    _buildScanningIndicator()
                        .animate()
                        .fadeIn(delay: 150.ms),

                  const SizedBox(height: 18),

                  // Section label
                  Text(
                    'AVAILABLE ADAPTERS',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Device list or placeholders
                  if (_devices.isEmpty && _isScanning)
                    _buildPlaceholderCards()
                  else
                    ..._devices.asMap().entries.map((entry) {
                      return _buildWifiDeviceCard(entry.value, entry.key)
                          .animate()
                          .fadeIn(
                              delay:
                                  Duration(milliseconds: entry.key * 140))
                          .slideY(begin: 0.15, end: 0);
                    }),

                  const SizedBox(height: 20),

                  // Manual connection card
                  _buildManualConnectionCard()
                      .animate()
                      .fadeIn(delay: 350.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom action bar
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildScanningIndicator() {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, child) {
        final dotCount = (_dotController.value * 3).floor() + 1;
        return Row(
          children: [
            ...List.generate(
              3,
              (i) => Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < dotCount
                      ? AppTheme.neonBlue
                      : AppTheme.glassBorder,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'SCANNING FOR ADAPTERS',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.neonBlue,
                letterSpacing: 1.5,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaceholderCards() {
    return Column(
      children: List.generate(
        2,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 74,
          decoration: BoxDecoration(
            color: AppTheme.charcoal,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.glassBorder, width: 1),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .shimmer(duration: const Duration(seconds: 2)),
      ),
    );
  }

  Widget _buildWifiDeviceCard(ScannedDevice device, int index) {
    final isSelected = _selectedDevice?.id == device.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedDevice = device),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.neonBlue.withValues(alpha: 0.08)
              : AppTheme.charcoal,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.neonBlue.withValues(alpha: 0.5)
                : AppTheme.glassBorder,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.neonBlue.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.neonCyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isSelected ? Icons.wifi : Icons.wifi_outlined,
                color: AppTheme.neonCyan,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Signal Strength: ${_signalLabel(device.signalStrength)}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              color: isSelected ? AppTheme.neonBlue : AppTheme.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualConnectionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.charcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.glassBorder,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Text(
            "Can't see your adapter?",
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You might need to manually enter the IP address\nof your OBD2 device.',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _showManualConnectionDialog,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.tune, color: AppTheme.neonBlue, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Manual Connection',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.neonBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final canConnect = _selectedDevice != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
      decoration: BoxDecoration(
        color: AppTheme.deepSpace,
        border: Border(
            top: BorderSide(color: AppTheme.glassBorder, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Connect Selected button
          GestureDetector(
            onTap: canConnect ? _connectSelected : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: canConnect
                    ? const LinearGradient(
                        colors: [AppTheme.neonBlue, AppTheme.neonCyan])
                    : null,
                color: canConnect ? null : AppTheme.charcoal,
                borderRadius: BorderRadius.circular(14),
                boxShadow: canConnect
                    ? [
                        BoxShadow(
                          color: AppTheme.neonBlue.withValues(alpha: 0.35),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  'Connect Selected',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: canConnect ? Colors.black : AppTheme.textMuted,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Retry scan
          GestureDetector(
            onTap: _isScanning ? null : _startScanning,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh,
                  size: 16,
                  color: _isScanning ? AppTheme.textMuted : Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  'Retry Scan',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isScanning ? AppTheme.textMuted : Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Troubleshooting connection issues?',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
