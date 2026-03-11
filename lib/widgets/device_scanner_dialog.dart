import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/bluetooth_service.dart';
import '../services/wifi_service.dart';

/// Enum to specify the type of scan
enum ScanType { bluetooth, wifi }

/// Model representing a scanned device (unified interface)
class ScannedDevice {
  final String id;
  final String name;
  final String? address;
  final int? signalStrength;
  final ScanType type;
  final dynamic rawDevice; // DiscoveredBluetoothDevice or DiscoveredWiFiNetwork

  ScannedDevice({
    required this.id,
    required this.name,
    this.address,
    this.signalStrength,
    required this.type,
    this.rawDevice,
  });

  int get signalBars {
    final signal = signalStrength ?? -70;
    if (signal >= -50) return 4;
    if (signal >= -60) return 3;
    if (signal >= -70) return 2;
    return 1;
  }
}

/// Professional device scanner dialog with REAL Bluetooth/WiFi scanning
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
  bool _hasError = false;
  String _errorMessage = '';
  List<ScannedDevice> _devices = [];
  String? _connectingDeviceId;

  // Services
  final BluetoothService _bluetoothService = BluetoothService.instance;
  final WifiService _wifiService = WifiService.instance;

  // Subscriptions
  StreamSubscription? _deviceSubscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startScanning();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _deviceSubscription?.cancel();
    if (widget.scanType == ScanType.bluetooth) {
      _bluetoothService.stopScan();
    } else {
      _wifiService.stopListening();
    }
    super.dispose();
  }

  /// Start real scanning
  Future<void> _startScanning() async {
    setState(() {
      _isScanning = true;
      _hasError = false;
      _errorMessage = '';
      _devices = [];
    });

    try {
      if (widget.scanType == ScanType.bluetooth) {
        await _startBluetoothScan();
      } else {
        await _startWifiScan();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _startBluetoothScan() async {
    // Check if Bluetooth is available
    final isAvailable = await _bluetoothService.isBluetoothAvailable();
    if (!isAvailable) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Bluetooth is not supported on this device';
        _isScanning = false;
      });
      return;
    }

    // Check if Bluetooth is on
    final isOn = await _bluetoothService.isBluetoothOn();
    if (!isOn) {
      await _bluetoothService.turnOnBluetooth();
      // Wait a bit for Bluetooth to turn on
      await Future.delayed(const Duration(seconds: 1));
      final isNowOn = await _bluetoothService.isBluetoothOn();
      if (!isNowOn) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Please enable Bluetooth in your device settings';
            _isScanning = false;
          });
        }
        return;
      }
    }

    // Listen to scan results
    _deviceSubscription?.cancel();
    _deviceSubscription = _bluetoothService.devicesStream.listen((devices) {
      if (mounted) {
        setState(() {
          _devices = devices
              .map((d) => ScannedDevice(
                    id: d.id,
                    name: d.name,
                    address: d.id,
                    signalStrength: d.rssi,
                    type: ScanType.bluetooth,
                    rawDevice: d,
                  ))
              .toList();
        });
      }
    });

    // Start scanning
    await _bluetoothService.startScan(
      timeout: const Duration(seconds: 12),
    );

    // Mark scanning as complete after timeout
    await Future.delayed(const Duration(seconds: 12));
    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _startWifiScan() async {
    // Listen to results
    _deviceSubscription?.cancel();
    _wifiService.startListening();
    _deviceSubscription = _wifiService.networksStream.listen((networks) {
      if (mounted) {
        setState(() {
          _devices = networks
              .map((n) => ScannedDevice(
                    id: n.bssid,
                    name: n.ssid,
                    address: n.bssid,
                    signalStrength: n.signalLevel,
                    type: ScanType.wifi,
                    rawDevice: n,
                  ))
              .toList();
        });
      }
    });

    // Trigger scan
    await _wifiService.startScan();

    // Mark as complete
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  /// Handle device selection
  Future<void> _onDeviceSelected(ScannedDevice device) async {
    setState(() {
      _connectingDeviceId = device.id;
    });

    try {
      if (device.type == ScanType.bluetooth) {
        final btDevice = device.rawDevice as DiscoveredBluetoothDevice;
        await _bluetoothService.connectToDevice(btDevice);
      } else {
        final wifiNetwork = device.rawDevice as DiscoveredWiFiNetwork;
        await _wifiService.connectToNetwork(wifiNetwork);
      }

      if (mounted) {
        widget.onDeviceSelected(device);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _connectingDeviceId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Connection failed: ${e.toString()}',
                    style: GoogleFonts.spaceGrotesk(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 550),
        decoration: BoxDecoration(
          color: AppTheme.midnightBlue,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.glassBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.scanType == ScanType.bluetooth
                      ? AppTheme.neonBlue
                      : AppTheme.neonCyan)
                  .withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(color: AppTheme.glassBorder, height: 1),
            Flexible(
              child: _hasError
                  ? _buildErrorView()
                  : (_isScanning && _devices.isEmpty
                      ? _buildScanningIndicator()
                      : _buildDeviceList()),
            ),
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
          Text(
            widget.scanType == ScanType.bluetooth
                ? 'Scanning Bluetooth'
                : 'Scanning Wi-Fi',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isScanning
                ? 'Looking for OBD-II devices nearby...'
                : _devices.isEmpty
                    ? 'No devices found'
                    : 'Found ${_devices.length} device${_devices.length != 1 ? 's' : ''}',
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

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Scan Error',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
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
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
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
          ).animate().fadeIn(),
          const SizedBox(height: 32),
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
      itemCount: _devices.length + (_isScanning ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _devices.length && _isScanning) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.neonCyan,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Still scanning...',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final device = _devices[index];
        return _buildDeviceItem(device, index)
            .animate()
            .fadeIn(delay: Duration(milliseconds: index * 80))
            .slideX(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildDeviceItem(ScannedDevice device, int index) {
    final isConnecting = _connectingDeviceId == device.id;
    final signalBars = device.signalBars;

    return GestureDetector(
      onTap: isConnecting ? null : () => _onDeviceSelected(device),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isConnecting
              ? AppTheme.neonBlue.withValues(alpha: 0.1)
              : AppTheme.charcoal,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConnecting ? AppTheme.neonBlue : AppTheme.glassBorder,
            width: isConnecting ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
            if (isConnecting)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.neonCyan,
                ),
              )
            else ...[
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
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
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
