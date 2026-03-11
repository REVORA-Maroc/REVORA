import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Connection state for OBD device
enum OBDConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
}

/// Represents a discovered Bluetooth device
class DiscoveredBluetoothDevice {
  final BluetoothDevice device;
  final String name;
  final String id;
  final int rssi;
  final List<String> serviceUuids;

  DiscoveredBluetoothDevice({
    required this.device,
    required this.name,
    required this.id,
    required this.rssi,
    this.serviceUuids = const [],
  });

  /// Signal strength as a human-readable string
  String get signalStrengthLabel {
    if (rssi >= -50) return 'Excellent';
    if (rssi >= -60) return 'Good';
    if (rssi >= -70) return 'Fair';
    return 'Weak';
  }

  /// Number of signal bars (1-4)
  int get signalBars {
    if (rssi >= -50) return 4;
    if (rssi >= -60) return 3;
    if (rssi >= -70) return 2;
    return 1;
  }
}

/// Bluetooth scanning and connection service using flutter_blue_plus
class BluetoothService {
  static BluetoothService? _instance;
  BluetoothService._();

  static BluetoothService get instance {
    _instance ??= BluetoothService._();
    return _instance!;
  }

  // State
  final _devicesController = StreamController<List<DiscoveredBluetoothDevice>>.broadcast();
  final _connectionStateController = StreamController<OBDConnectionState>.broadcast();
  final _connectedDeviceController = StreamController<DiscoveredBluetoothDevice?>.broadcast();

  List<DiscoveredBluetoothDevice> _discoveredDevices = [];
  OBDConnectionState _connectionState = OBDConnectionState.disconnected;
  BluetoothDevice? _connectedDevice;
  DiscoveredBluetoothDevice? _connectedDiscoveredDevice;
  StreamSubscription<BluetoothConnectionState>? _deviceStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  // Streams
  Stream<List<DiscoveredBluetoothDevice>> get devicesStream => _devicesController.stream;
  Stream<OBDConnectionState> get connectionStateStream => _connectionStateController.stream;
  Stream<DiscoveredBluetoothDevice?> get connectedDeviceStream => _connectedDeviceController.stream;

  // Getters
  List<DiscoveredBluetoothDevice> get discoveredDevices => _discoveredDevices;
  OBDConnectionState get connectionState => _connectionState;
  DiscoveredBluetoothDevice? get connectedDevice => _connectedDiscoveredDevice;
  bool get isConnected => _connectionState == OBDConnectionState.connected;
  bool get isScanning => FlutterBluePlus.isScanningNow;

  /// Check if Bluetooth is supported and available
  Future<bool> isBluetoothAvailable() async {
    try {
      return await FlutterBluePlus.isSupported;
    } catch (e) {
      debugPrint('BluetoothService: Error checking Bluetooth support: $e');
      return false;
    }
  }

  /// Check if Bluetooth is currently on
  Future<bool> isBluetoothOn() async {
    try {
      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      debugPrint('BluetoothService: Error checking Bluetooth state: $e');
      return false;
    }
  }

  /// Request required permissions
  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  /// Turn on Bluetooth
  Future<void> turnOnBluetooth() async {
    try {
      await FlutterBluePlus.turnOn();
    } catch (e) {
      debugPrint('BluetoothService: Cannot turn on Bluetooth: $e');
    }
  }

  /// Start scanning for Bluetooth devices
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    // Clear previous results
    _discoveredDevices = [];
    _devicesController.add(_discoveredDevices);

    // Cancel any previous scan subscription
    await _scanSubscription?.cancel();

    try {
      // Listen to scan results
      _scanSubscription = FlutterBluePlus.onScanResults.listen(
        (results) {
          _discoveredDevices = results
              .where((r) => r.device.platformName.isNotEmpty)
              .map((r) => DiscoveredBluetoothDevice(
                    device: r.device,
                    name: r.device.platformName.isNotEmpty
                        ? r.device.platformName
                        : 'Unknown Device',
                    id: r.device.remoteId.str,
                    rssi: r.rssi,
                    serviceUuids: r.advertisementData.serviceUuids
                        .map((e) => e.str)
                        .toList(),
                  ))
              .toList();

          // Sort by signal strength
          _discoveredDevices.sort((a, b) => b.rssi.compareTo(a.rssi));
          _devicesController.add(_discoveredDevices);
        },
        onError: (e) {
          debugPrint('BluetoothService: Scan error: $e');
        },
      );

      // Start the scan
      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: true,
      );
    } catch (e) {
      debugPrint('BluetoothService: Failed to start scan: $e');
      rethrow;
    }
  }

  /// Stop scanning
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
    } catch (e) {
      debugPrint('BluetoothService: Failed to stop scan: $e');
    }
  }

  /// Connect to a Bluetooth device
  Future<void> connectToDevice(DiscoveredBluetoothDevice discoveredDevice) async {
    _setConnectionState(OBDConnectionState.connecting);

    try {
      // Disconnect existing connection if any
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }

      final device = discoveredDevice.device;

      // Listen for connection state
      _deviceStateSubscription?.cancel();
      _deviceStateSubscription = device.connectionState.listen(
        (state) {
          if (state == BluetoothConnectionState.connected) {
            _connectedDevice = device;
            _connectedDiscoveredDevice = discoveredDevice;
            _setConnectionState(OBDConnectionState.connected);
            _connectedDeviceController.add(_connectedDiscoveredDevice);
          } else if (state == BluetoothConnectionState.disconnected) {
            _connectedDevice = null;
            _connectedDiscoveredDevice = null;
            _setConnectionState(OBDConnectionState.disconnected);
            _connectedDeviceController.add(null);
          }
        },
        onError: (error) {
          debugPrint('BluetoothService: Connection state error: $error');
          _setConnectionState(OBDConnectionState.disconnected);
        },
      );

      // Connect
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );
    } catch (e) {
      debugPrint('BluetoothService: Connection failed: $e');
      _setConnectionState(OBDConnectionState.disconnected);
      _connectedDeviceController.add(null);
      rethrow;
    }
  }

  /// Disconnect from the current device
  Future<void> disconnect() async {
    _setConnectionState(OBDConnectionState.disconnecting);
    try {
      await _deviceStateSubscription?.cancel();
      _deviceStateSubscription = null;

      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
      }
    } catch (e) {
      debugPrint('BluetoothService: Disconnect error: $e');
    } finally {
      _connectedDevice = null;
      _connectedDiscoveredDevice = null;
      _setConnectionState(OBDConnectionState.disconnected);
      _connectedDeviceController.add(null);
    }
  }

  void _setConnectionState(OBDConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  /// Dispose all resources
  void dispose() {
    _scanSubscription?.cancel();
    _deviceStateSubscription?.cancel();
    _devicesController.close();
    _connectionStateController.close();
    _connectedDeviceController.close();
  }
}
