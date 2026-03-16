import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart' as bt_classic;
import 'package:permission_handler/permission_handler.dart';

import '../widgets/device_scanner_dialog.dart';

enum OBDConnectionStatus { disconnected, connecting, connected, failed }

class OBDBluetoothService {
  static final OBDBluetoothService _instance = OBDBluetoothService._internal();
  factory OBDBluetoothService() => _instance;
  OBDBluetoothService._internal();

  final BluetoothClassic _classicBt = BluetoothClassic();

  final StreamController<List<ScannedDevice>> _devicesController =
      StreamController<List<ScannedDevice>>.broadcast();
  final StreamController<OBDConnectionStatus> _connectionStatusController =
      StreamController<OBDConnectionStatus>.broadcast();

  Stream<List<ScannedDevice>> get devicesStream => _devicesController.stream;
  Stream<OBDConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  final Map<String, ScannedDevice> _deviceMap = {};

  StreamSubscription? _bleScanSubscription;
  StreamSubscription? _classicDiscoverySubscription;
  StreamSubscription? _bleConnectionSubscription;

  fbp.BluetoothDevice? _connectedBleDevice;
  bool _classicConnected = false;
  bool _isScanning = false;

  bool get isScanning => _isScanning;
  bool get isConnected => _connectedBleDevice != null || _classicConnected;

  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    final permissions = <Permission>[
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ];

    final statuses = await permissions.request();
    return statuses.values
        .every((s) => s.isGranted || s.isLimited || s.isPermanentlyDenied == false);
  }

  Future<void> startScan({Duration timeout = const Duration(seconds: 12)}) async {
    if (_isScanning) await stopScan();

    _deviceMap.clear();
    _devicesController.add([]);
    _isScanning = true;

    await _loadPairedClassicDevices();
    await _startBleScan(timeout: timeout);
    _startClassicScan();

    Future.delayed(timeout, () {
      if (_isScanning) {
        _isScanning = false;
        stopScan();
      }
    });
  }

  Future<void> _loadPairedClassicDevices() async {
    try {
      await _classicBt.initPermissions();
      final paired = await _classicBt.getPairedDevices();
      for (final device in paired) {
        _upsertDevice(ScannedDevice(
          id: device.address,
          name: (device.name?.isNotEmpty == true) ? device.name! : 'Unknown Device',
          address: device.address,
          signalStrength: null,
          type: ScanType.bluetooth,
          protocol: BluetoothProtocol.classic,
        ));
      }
    } catch (_) {}
  }

  Future<void> _startBleScan({required Duration timeout}) async {
    _bleScanSubscription?.cancel();

    try {
      final adapterState = await fbp.FlutterBluePlus.adapterState
          .where((s) => s != fbp.BluetoothAdapterState.unknown)
          .first
          .timeout(const Duration(seconds: 3));

      if (adapterState != fbp.BluetoothAdapterState.on) return;

      _bleScanSubscription =
          fbp.FlutterBluePlus.onScanResults.listen((results) {
        for (final r in results) {
          final name = r.device.platformName.isNotEmpty
              ? r.device.platformName
              : r.advertisementData.advName;
          if (name.isEmpty) continue;

          final mac = r.device.remoteId.str;
          final existing = _deviceMap[mac];
          if (existing?.protocol == BluetoothProtocol.classic) {
            _upsertDevice(ScannedDevice(
              id: mac,
              name: name,
              address: mac,
              signalStrength: r.rssi,
              type: ScanType.bluetooth,
              protocol: BluetoothProtocol.classic,
            ));
          } else {
            _upsertDevice(ScannedDevice(
              id: mac,
              name: name,
              address: mac,
              signalStrength: r.rssi,
              type: ScanType.bluetooth,
              protocol: BluetoothProtocol.ble,
            ));
          }
        }
      }, onError: (_) {});

      fbp.FlutterBluePlus.cancelWhenScanComplete(_bleScanSubscription!);
      await fbp.FlutterBluePlus.startScan(timeout: timeout);
    } catch (_) {}
  }

  void _startClassicScan() {
    _classicDiscoverySubscription?.cancel();

    try {
      _classicDiscoverySubscription =
          _classicBt.onDeviceDiscovered().listen((bt_classic.Device device) {
        final mac = device.address;
        final existing = _deviceMap[mac];
        if (existing?.protocol == BluetoothProtocol.ble) return;

        _upsertDevice(ScannedDevice(
          id: mac,
          name: (device.name?.isNotEmpty == true) ? device.name! : 'Unknown Device',
          address: mac,
          signalStrength: null,
          type: ScanType.bluetooth,
          protocol: BluetoothProtocol.classic,
        ));
      });
      _classicBt.startScan();
    } catch (_) {}
  }

  void _upsertDevice(ScannedDevice device) {
    if (device.address == null || device.address!.isEmpty) return;
    _deviceMap[device.address!] = device;
    final sorted = _deviceMap.values.toList()
      ..sort((a, b) =>
          (b.signalStrength ?? -100).compareTo(a.signalStrength ?? -100));
    _devicesController.add(List.unmodifiable(sorted));
  }

  Future<void> stopScan() async {
    _isScanning = false;
    _bleScanSubscription?.cancel();
    _bleScanSubscription = null;
    _classicDiscoverySubscription?.cancel();
    _classicDiscoverySubscription = null;

    try {
      if (fbp.FlutterBluePlus.isScanningNow) {
        await fbp.FlutterBluePlus.stopScan();
      }
    } catch (_) {}
    try {
      await _classicBt.stopScan();
    } catch (_) {}
  }

  Future<bool> connect(ScannedDevice device) async {
    _connectionStatusController.add(OBDConnectionStatus.connecting);
    if (device.protocol == BluetoothProtocol.ble) {
      return _connectBle(device);
    } else {
      return _connectClassic(device);
    }
  }

  Future<bool> _connectBle(ScannedDevice device) async {
    try {
      final bleDevice = fbp.BluetoothDevice.fromId(device.address!);

      _bleConnectionSubscription?.cancel();
      _bleConnectionSubscription =
          bleDevice.connectionState.listen((state) async {
        if (state == fbp.BluetoothConnectionState.disconnected) {
          _connectedBleDevice = null;
          _connectionStatusController.add(OBDConnectionStatus.disconnected);
        }
      });
      bleDevice.cancelWhenDisconnected(_bleConnectionSubscription!,
          delayed: true, next: true);

      await bleDevice.connect(
        license: fbp.License.free,
        timeout: const Duration(seconds: 15),
        mtu: null,
      );

      _connectedBleDevice = bleDevice;
      _connectionStatusController.add(OBDConnectionStatus.connected);
      return true;
    } catch (_) {
      _connectionStatusController.add(OBDConnectionStatus.failed);
      return false;
    }
  }

  Future<bool> _connectClassic(ScannedDevice device) async {
    const sppUuid = '00001101-0000-1000-8000-00805f9b34fb';
    try {
      await _classicBt.connect(device.address!, sppUuid);
      _classicConnected = true;
      _connectionStatusController.add(OBDConnectionStatus.connected);
      return true;
    } catch (_) {
      _connectionStatusController.add(OBDConnectionStatus.failed);
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      if (_connectedBleDevice != null) {
        await _connectedBleDevice!.disconnect();
        _connectedBleDevice = null;
      }
    } catch (_) {}

    try {
      if (_classicConnected) {
        await _classicBt.disconnect();
        _classicConnected = false;
      }
    } catch (_) {}

    _connectionStatusController.add(OBDConnectionStatus.disconnected);
  }

  void dispose() {
    stopScan();
    disconnect();
    _devicesController.close();
    _connectionStatusController.close();
  }
}
