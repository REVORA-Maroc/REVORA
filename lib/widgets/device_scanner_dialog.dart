import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Enum to specify the type of scan
enum ScanType { bluetooth, wifi }

/// Model representing a scanned device
class ScannedDevice {
  final String id;
  final String name;
  final String? address;
  final int? signalStrength;
  final ScanType type;

  ScannedDevice({
    required this.id,
    required this.name,
    this.address,
    this.signalStrength,
    required this.type,
  });
}

/// Professional device scanner dialog with scanning animation
/// and device list display
class DeviceScannerDialog extends StatefulWidget {
  final ScanType scanType;
  final Function(ScannedDevice) onDeviceSelected;

  const DeviceScannerDialog({
    super.key,
    required this.scanType,
    required this.onDeviceSelected,
  });

  @override
  State<DeviceScannerDialog> createState() => _DeviceScannerDialogState();
}

class _DeviceScannerDialogState extends State<DeviceScannerDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isScanning = true;
  List<ScannedDevice> _devices = [];
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Start scanning
    _startScanning();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  /// Simulate device scanning (replace with actual Bluetooth/Wi-Fi scanning)
  void _startScanning() {
    setState(() {
      _isScanning = true;
      _devices = [];
    });

    // Simulate finding devices over time
    int deviceCount = 0;
    _scanTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (deviceCount < 4) {
        setState(() {
          _devices.add(_generateMockDevice(deviceCount));
        });
        deviceCount++;
      } else {
        // Stop scanning after 5 seconds
        if (timer.tick >= 5) {
          setState(() {
            _isScanning = false;
          });
          timer.cancel();
        }
      }
    });
  }

  /// Generate mock device for demonstration
  ScannedDevice _generateMockDevice(int index) {
    final isBluetooth = widget.scanType == ScanType.bluetooth;
    final deviceNames = isBluetooth
        ? ['OBD-II Scanner', 'Car Diagnostics Pro', 'ELM327 Adapter', 'Veepeak OBD']
        : ['OBDLink MX+', 'Wi-Fi OBD Adapter', 'Carista Adapter', 'OBDeleven'];

    return ScannedDevice(
      id: 'device_$index',
      name: deviceNames[index],
      address: isBluetooth ? '00:11:22:33:44:5$index' : '192.168.0.${10 + index}',
      signalStrength: -50 - (index * 5),
      type: widget.scanType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: AppTheme.midnightBlue,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.glassBorder,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            const Divider(color: AppTheme.glassBorder, height: 1),

            // Content
            Flexible(
              child: _isScanning && _devices.isEmpty
                  ? _buildScanningIndicator()
                  : _buildDeviceList(),
            ),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.scanType == ScanType.bluetooth
                  ? AppTheme.neonBlue.withValues(alpha: 0.2)
                  : AppTheme.neonCyan.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.scanType == ScanType.bluetooth
                  ? Icons.bluetooth_searching
                  : Icons.wifi_find,
              color: widget.scanType == ScanType.bluetooth
                  ? AppTheme.neonBlue
                  : AppTheme.neonCyan,
              size: 32,
            ),
          )
              .animate()
              .scale(duration: const Duration(milliseconds: 300)),

          const SizedBox(height: 16),

          // Title
          Text(
            widget.scanType == ScanType.bluetooth
                ? 'Scanning for Bluetooth'
                : 'Scanning for Wi-Fi',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          // Subtitle
          Text(
            _isScanning
                ? 'Looking for available OBD-II devices...'
                : 'Found ${_devices.length} devices',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningIndicator() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated scanning circles
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.neonBlue.withValues(
                          alpha: 0.3 + (0.3 * _animationController.value),
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                  // Middle ring
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.neonCyan.withValues(
                          alpha: 0.4 + (0.4 * (1 - _animationController.value)),
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                  // Center icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.charcoal,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.scanType == ScanType.bluetooth
                          ? Icons.bluetooth
                          : Icons.wifi,
                      color: AppTheme.neonBlue,
                      size: 28,
                    ),
                  ),
                ],
              );
            },
          )
              .animate()
              .fadeIn(),

          const SizedBox(height: 32),

          // Scanning text with dots animation
          _buildScanningText(),
        ],
      ),
    );
  }

  Widget _buildScanningText() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        int dots = (_animationController.value * 3).floor() + 1;
        return Text(
          'Scanning${'.' * dots}',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        );
      },
    );
  }

  Widget _buildDeviceList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        return _buildDeviceItem(device, index)
            .animate()
            .fadeIn(delay: Duration(milliseconds: index * 100))
            .slideX(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildDeviceItem(ScannedDevice device, int index) {
    final signalStrength = device.signalStrength ?? -70;
    final signalBars = signalStrength > -50 ? 4 : signalStrength > -60 ? 3 : signalStrength > -70 ? 2 : 1;

    return GestureDetector(
      onTap: () => widget.onDeviceSelected(device),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.charcoal,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Device icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.scanType == ScanType.bluetooth
                    ? AppTheme.neonBlue.withValues(alpha: 0.1)
                    : AppTheme.neonCyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.scanType == ScanType.bluetooth
                    ? Icons.bluetooth
                    : Icons.wifi,
                color: widget.scanType == ScanType.bluetooth
                    ? AppTheme.neonBlue
                    : AppTheme.neonCyan,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            // Device info
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
                  const SizedBox(height: 2),
                  Text(
                    device.address ?? 'Unknown address',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Signal strength
            Row(
              children: [
                ...List.generate(4, (i) {
                  return Container(
                    width: 3,
                    height: 6 + (i * 3),
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: i < signalBars
                          ? AppTheme.neonCyan
                          : AppTheme.glassBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(width: 8),

            // Arrow
            Icon(
              Icons.chevron_right,
              color: AppTheme.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Rescan button
          Expanded(
            child: GestureDetector(
              onTap: _isScanning ? null : _startScanning,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isScanning ? AppTheme.glassBorder : AppTheme.charcoal,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.glassBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: _isScanning ? AppTheme.textMuted : Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Rescan',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isScanning ? AppTheme.textMuted : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Cancel button
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.neonBlue, AppTheme.neonCyan],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
