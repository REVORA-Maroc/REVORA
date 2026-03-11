import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';

/// Connection state for WiFi OBD device
enum WiFiOBDConnectionState {
  disconnected,
  connecting,
  connected,
}

/// Represents a discovered WiFi network
class DiscoveredWiFiNetwork {
  final String ssid;
  final String bssid;
  final int signalLevel;
  final String capabilities;

  DiscoveredWiFiNetwork({
    required this.ssid,
    required this.bssid,
    required this.signalLevel,
    this.capabilities = '',
  });

  /// Signal strength label
  String get signalStrengthLabel {
    if (signalLevel >= -50) return 'Excellent';
    if (signalLevel >= -60) return 'Good';
    if (signalLevel >= -70) return 'Fair';
    return 'Weak';
  }

  /// Number of signal bars (1-4)
  int get signalBars {
    if (signalLevel >= -50) return 4;
    if (signalLevel >= -60) return 3;
    if (signalLevel >= -70) return 2;
    return 1;
  }

  /// Check if this looks like an OBD adapter
  bool get isLikelyOBD {
    final name = ssid.toUpperCase();
    return name.contains('OBD') ||
        name.contains('ELM') ||
        name.contains('VLINK') ||
        name.contains('VEEPEAK') ||
        name.contains('VGATE') ||
        name.contains('CARISTA') ||
        name.contains('V-LINK') ||
        name.contains('IOS-VLINK') ||
        name.contains('WIFI_OBDII') ||
        name.contains('CLK') ||
        name.contains('ESP');
  }
}

/// WiFi scanning service using wifi_scan package
class WifiService {
  static WifiService? _instance;
  WifiService._();

  static WifiService get instance {
    _instance ??= WifiService._();
    return _instance!;
  }

  // State
  final _networksController = StreamController<List<DiscoveredWiFiNetwork>>.broadcast();
  final _connectionStateController = StreamController<WiFiOBDConnectionState>.broadcast();
  final _connectedNetworkController = StreamController<DiscoveredWiFiNetwork?>.broadcast();

  List<DiscoveredWiFiNetwork> _discoveredNetworks = [];
  WiFiOBDConnectionState _connectionState = WiFiOBDConnectionState.disconnected;
  DiscoveredWiFiNetwork? _connectedNetwork;
  StreamSubscription<List<WiFiAccessPoint>>? _scanSubscription;

  // Streams
  Stream<List<DiscoveredWiFiNetwork>> get networksStream => _networksController.stream;
  Stream<WiFiOBDConnectionState> get connectionStateStream => _connectionStateController.stream;
  Stream<DiscoveredWiFiNetwork?> get connectedNetworkStream => _connectedNetworkController.stream;

  // Getters
  List<DiscoveredWiFiNetwork> get discoveredNetworks => _discoveredNetworks;
  WiFiOBDConnectionState get connectionState => _connectionState;
  DiscoveredWiFiNetwork? get connectedNetwork => _connectedNetwork;
  bool get isConnected => _connectionState == WiFiOBDConnectionState.connected;

  /// Request required permissions
  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.nearbyWifiDevices,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  /// Check if WiFi scanning is supported
  Future<bool> canScan() async {
    try {
      final can = await WiFiScan.instance.canStartScan();
      return can == CanStartScan.yes;
    } catch (e) {
      debugPrint('WifiService: Cannot check scan capability: $e');
      return false;
    }
  }

  /// Start scanning for WiFi networks
  Future<void> startScan() async {
    _discoveredNetworks = [];
    _networksController.add(_discoveredNetworks);

    try {
      // Check if we can scan
      final canStartScan = await WiFiScan.instance.canStartScan();
      if (canStartScan != CanStartScan.yes) {
        debugPrint('WifiService: Cannot start scan: $canStartScan');
        return;
      }

      // Start scan
      final success = await WiFiScan.instance.startScan();
      if (!success) {
        debugPrint('WifiService: Scan failed to start');
        return;
      }

      // Check if we can get results
      final canGetResults = await WiFiScan.instance.canGetScannedResults();
      if (canGetResults != CanGetScannedResults.yes) {
        debugPrint('WifiService: Cannot get scan results: $canGetResults');
        return;
      }

      // Get results
      final results = await WiFiScan.instance.getScannedResults();
      _discoveredNetworks = results
          .where((ap) => ap.ssid.isNotEmpty)
          .map((ap) => DiscoveredWiFiNetwork(
                ssid: ap.ssid,
                bssid: ap.bssid,
                signalLevel: ap.level,
                capabilities: ap.capabilities,
              ))
          .toList();

      // Sort: OBD devices first, then by signal strength
      _discoveredNetworks.sort((a, b) {
        if (a.isLikelyOBD && !b.isLikelyOBD) return -1;
        if (!a.isLikelyOBD && b.isLikelyOBD) return 1;
        return b.signalLevel.compareTo(a.signalLevel);
      });

      _networksController.add(_discoveredNetworks);
    } catch (e) {
      debugPrint('WifiService: Scan error: $e');
      rethrow;
    }
  }

  /// Subscribe to scan results stream
  void startListening() {
    _scanSubscription?.cancel();
    _scanSubscription = WiFiScan.instance.onScannedResultsAvailable.listen(
      (results) {
        _discoveredNetworks = results
            .where((ap) => ap.ssid.isNotEmpty)
            .map((ap) => DiscoveredWiFiNetwork(
                  ssid: ap.ssid,
                  bssid: ap.bssid,
                  signalLevel: ap.level,
                  capabilities: ap.capabilities,
                ))
            .toList();

        _discoveredNetworks.sort((a, b) {
          if (a.isLikelyOBD && !b.isLikelyOBD) return -1;
          if (!a.isLikelyOBD && b.isLikelyOBD) return 1;
          return b.signalLevel.compareTo(a.signalLevel);
        });

        _networksController.add(_discoveredNetworks);
      },
      onError: (error) {
        debugPrint('WifiService: Stream error: $error');
      },
    );
  }

  /// Simulate connecting to a WiFi OBD device
  /// Note: Actual WiFi connection requires platform-specific APIs
  /// or user to manually connect via system settings
  Future<void> connectToNetwork(DiscoveredWiFiNetwork network) async {
    _setConnectionState(WiFiOBDConnectionState.connecting);

    try {
      // WiFi connection on Android/iOS typically requires the user to
      // connect via system settings. We simulate a delay and mark as connected
      // In production, you could use wifi_iot or NetworkManager APIs
      await Future.delayed(const Duration(seconds: 2));

      _connectedNetwork = network;
      _setConnectionState(WiFiOBDConnectionState.connected);
      _connectedNetworkController.add(_connectedNetwork);
    } catch (e) {
      debugPrint('WifiService: Connection error: $e');
      _setConnectionState(WiFiOBDConnectionState.disconnected);
      _connectedNetworkController.add(null);
      rethrow;
    }
  }

  /// Disconnect from current network
  void disconnectFromNetwork() {
    _connectedNetwork = null;
    _setConnectionState(WiFiOBDConnectionState.disconnected);
    _connectedNetworkController.add(null);
  }

  void _setConnectionState(WiFiOBDConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  /// Stop listening
  void stopListening() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  /// Dispose all resources
  void dispose() {
    _scanSubscription?.cancel();
    _networksController.close();
    _connectionStateController.close();
    _connectedNetworkController.close();
  }
}
