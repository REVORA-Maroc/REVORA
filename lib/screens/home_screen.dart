import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../widgets/device_scanner_dialog.dart';
import '../services/bluetooth_service.dart';
import '../services/wifi_service.dart';
import '../services/vehicle_service.dart';
import '../models/vehicle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final BluetoothService _btService = BluetoothService.instance;
  final WifiService _wifiService = WifiService.instance;
  final VehicleService _vehicleService = VehicleService.instance;

  OBDConnectionState _btState = OBDConnectionState.disconnected;
  WiFiOBDConnectionState _wifiState = WiFiOBDConnectionState.disconnected;
  String _connectedDeviceName = '';
  String _connectionType = '';
  Vehicle? _selectedVehicle;
  List<Vehicle> _vehicles = [];

  StreamSubscription? _btStateSub;
  StreamSubscription? _wifiStateSub;
  StreamSubscription? _btDeviceSub;
  StreamSubscription? _wifiNetSub;

  @override
  void initState() {
    super.initState();
    _initListeners();
    _loadVehicles();
  }

  void _initListeners() {
    _btStateSub = _btService.connectionStateStream.listen((s) {
      if (mounted) setState(() => _btState = s);
    });
    _wifiStateSub = _wifiService.connectionStateStream.listen((s) {
      if (mounted) setState(() => _wifiState = s);
    });
    _btDeviceSub = _btService.connectedDeviceStream.listen((d) {
      if (mounted) setState(() {
        _connectedDeviceName = d?.name ?? '';
        if (d != null) _connectionType = 'Bluetooth';
      });
    });
    _wifiNetSub = _wifiService.connectedNetworkStream.listen((n) {
      if (mounted) setState(() {
        _connectedDeviceName = n?.ssid ?? '';
        if (n != null) _connectionType = 'Wi-Fi';
      });
    });
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await _vehicleService.getAllVehicles();
      final selected = await _vehicleService.getSelectedVehicle();
      if (mounted) setState(() { _vehicles = vehicles; _selectedVehicle = selected; });
    } catch (_) {}
  }

  @override
  void dispose() {
    _btStateSub?.cancel();
    _wifiStateSub?.cancel();
    _btDeviceSub?.cancel();
    _wifiNetSub?.cancel();
    super.dispose();
  }

  bool get _isConnected =>
      _btState == OBDConnectionState.connected ||
      _wifiState == WiFiOBDConnectionState.connected;

  bool get _isConnecting =>
      _btState == OBDConnectionState.connecting ||
      _wifiState == WiFiOBDConnectionState.connecting;

  String get _connectionStatusText {
    if (_isConnected) return 'Connected';
    if (_isConnecting) return 'Connecting...';
    return 'Disconnected';
  }

  Color get _statusColor {
    if (_isConnected) return AppTheme.electricGreen;
    if (_isConnecting) return Colors.amber;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepSpace,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildConnectionStatusCard().animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 16),
                    _buildVehicleCard().animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 16),
                    _buildScanButtonsCard().animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 16),
                    _buildFeatureGrid().animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ====================== HEADER ======================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.charcoal.withValues(alpha: 0.7),
        border: Border(bottom: BorderSide(color: AppTheme.glassBorder, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: AppTheme.neonCyan.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 2)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/images/revora_logo.png', width: 60, height: 60, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [AppTheme.neonCyan, AppTheme.neonBlue])),
                    child: const Icon(Icons.electric_car, size: 24, color: Colors.black),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).scale(delay: 100.ms).then().shimmer(duration: 2.seconds),
            const SizedBox(width: 12),
            Text('', style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5))
                .animate().fadeIn(delay: 150.ms).slideX(begin: -0.2, end: 0),
          ]),
          Row(children: [
            _buildStatusBadge(),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
              ),
            ).animate().fadeIn(delay: 200.ms),
          ]),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.charcoal.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _statusColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: _statusColor, borderRadius: BorderRadius.circular(4),
            boxShadow: [BoxShadow(color: _statusColor.withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 2)]),
        ),
        const SizedBox(width: 6),
        Text(
          _isConnected ? 'ONLINE' : (_isConnecting ? 'LINKING' : 'OFFLINE'),
          style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w600, color: _statusColor, letterSpacing: 1.5),
        ),
      ]),
    );
  }

  // ====================== CONNECTION STATUS CARD ======================
  Widget _buildConnectionStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: _isConnected
              ? [AppTheme.electricGreen.withValues(alpha: 0.15), AppTheme.charcoal]
              : [AppTheme.charcoal, AppTheme.midnightBlue]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _isConnected ? AppTheme.electricGreen.withValues(alpha: 0.3) : AppTheme.glassBorder, width: 1),
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(
            _isConnected ? Icons.bluetooth_connected : (_isConnecting ? Icons.bluetooth_searching : Icons.bluetooth_disabled),
            color: _statusColor, size: 28,
          ),
        ).animate().scale(delay: 100.ms),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_connectionStatusText, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: _statusColor)),
          const SizedBox(height: 4),
          Text(
            _isConnected ? '$_connectedDeviceName via $_connectionType' : 'No OBD-II device connected',
            style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ])),
        if (_isConnected)
          GestureDetector(
            onTap: _disconnect,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Text('Disconnect', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.redAccent)),
            ),
          ),
      ]),
    );
  }

  // ====================== VEHICLE CARD ======================
  Widget _buildVehicleCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.charcoal, AppTheme.midnightBlue]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(children: [
          Positioned(right: -50, top: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.neonBlue.withValues(alpha: 0.1)))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_selectedVehicle?.shortName ?? 'No Vehicle Selected',
                    style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(_selectedVehicle != null ? '${_selectedVehicle!.year}' : 'Add a vehicle to get started',
                    style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.neonBlue)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.neonBlue.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(_vehicles.length == 1 ? '1 VEHICLE' : '${_vehicles.length} VEHICLES',
                    style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.neonBlue, letterSpacing: 1.5)),
                ),
              ]),
              const SizedBox(height: 12),
              if (_selectedVehicle != null)
                Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: Icon(Icons.directions_car, size: 60, color: AppTheme.neonBlue.withValues(alpha: 0.5)),
                ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _showVehicleManager,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.neonBlue, AppTheme.neonCyan]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: AppTheme.neonBlue.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.garage_rounded, color: Colors.black, size: 20),
                    const SizedBox(width: 8),
                    Text('Manage Vehicles', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)),
                  ]),
                ),
              ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms),
            ]),
          ),
        ]),
      ),
    );
  }

  // ====================== SCAN BUTTONS ======================
  Widget _buildScanButtonsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.midnightBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.glassBorder, width: 1),
      ),
      child: Column(children: [
        Row(children: [
          Icon(Icons.radar, color: AppTheme.neonCyan, size: 20),
          const SizedBox(width: 8),
          Text('Device Scanner', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
        const SizedBox(height: 6),
        Text('Scan for nearby OBD-II adapters using Bluetooth or Wi-Fi', style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _buildScanButton(icon: Icons.bluetooth, label: 'Bluetooth Scan', color: AppTheme.neonBlue, onTap: _requestBluetoothPermission, isPrimary: true)),
          const SizedBox(width: 12),
          Expanded(child: _buildScanButton(icon: Icons.wifi, label: 'Wi-Fi Scan', color: AppTheme.neonCyan, onTap: _requestWifiPermission, isPrimary: false)),
        ]).animate().fadeIn(delay: 250.ms),
      ]),
    );
  }

  Widget _buildScanButton({required IconData icon, required String label, required Color color, required VoidCallback onTap, required bool isPrimary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isPrimary ? LinearGradient(colors: [color, color.withValues(alpha: 0.8)]) : null,
          color: isPrimary ? null : AppTheme.charcoal,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: color.withValues(alpha: 0.3), width: 1),
          boxShadow: isPrimary ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: isPrimary ? Colors.black : color, size: 18),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w700, color: isPrimary ? Colors.black : color)),
        ]),
      ),
    );
  }

  // ====================== FEATURE GRID ======================
  Widget _buildFeatureGrid() {
    return Column(children: [
      Row(children: [
        Expanded(child: _buildFeatureCard(icon: Icons.health_and_safety, iconColor: Colors.orange, title: 'Diagnostics', subtitle: 'Check vehicle health', onTap: () {}).animate().fadeIn(delay: 100.ms).scale(delay: 100.ms)),
        const SizedBox(width: 12),
        Expanded(child: _buildFeatureCard(icon: Icons.speed, iconColor: AppTheme.neonBlue, title: 'Dashboard', subtitle: 'Real-time gauges', onTap: () {}).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms)),
      ]),
      const SizedBox(height: 12),
      _buildLiveDataCard().animate().fadeIn(delay: 300.ms).slideX(begin: 0.2, end: 0),
    ]);
  }

  Widget _buildFeatureCard({required IconData icon, required Color iconColor, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppTheme.charcoal, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.glassBorder, width: 1)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 28),
          ).animate().scale(delay: 100.ms),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppTheme.textSecondary)),
        ]),
      ),
    );
  }

  Widget _buildLiveDataCard() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppTheme.charcoal, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.glassBorder, width: 1)),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.neonCyan.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.query_stats, color: AppTheme.neonCyan, size: 28),
          ).animate().rotate(delay: 100.ms),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Live Data', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 2),
            Text('Sensor values & performance telemetry', style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppTheme.textSecondary)),
          ])),
          const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 24),
        ]),
      ),
    );
  }

  // ====================== BOTTOM NAV ======================
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.charcoal.withValues(alpha: 0.9), border: Border(top: BorderSide(color: AppTheme.glassBorder, width: 1))),
      child: SafeArea(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _buildNavItem(Icons.home, 'Home', 0),
        _buildNavItem(Icons.build, 'Diag', 1),
        _buildNavItem(Icons.psychology, 'Insights', 2),
        _buildNavItem(Icons.route, 'Trips', 3),
      ])),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? AppTheme.neonBlue.withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: isSelected ? AppTheme.neonBlue : AppTheme.textSecondary, size: 24, fill: isSelected ? 1.0 : 0.0),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: GoogleFonts.spaceGrotesk(fontSize: 10, fontWeight: FontWeight.w700, color: isSelected ? AppTheme.neonBlue : AppTheme.textSecondary, letterSpacing: 1.5)),
        ]),
      ),
    );
  }

  // ====================== ACTIONS ======================
  Future<void> _requestBluetoothPermission() async {
    if (!mounted) return;
    Map<Permission, PermissionStatus> statuses = await [Permission.bluetooth, Permission.bluetoothScan, Permission.bluetoothConnect, Permission.location].request();
    bool allGranted = statuses.values.every((s) => s.isGranted);
    if (!mounted) return;
    if (allGranted) {
      showDialog(context: context, builder: (ctx) => DeviceScannerDialog(
        scanType: ScanType.bluetooth,
        onDeviceSelected: (device) { Navigator.pop(ctx); if (mounted) { setState(() {}); _showSuccessSnackBar('Connected to ${device.name}'); } },
      ));
    } else {
      _showErrorSnackBar('Bluetooth permissions are required');
    }
  }

  Future<void> _requestWifiPermission() async {
    if (!mounted) return;
    Map<Permission, PermissionStatus> statuses = await [Permission.location, Permission.nearbyWifiDevices].request();
    bool allGranted = statuses.values.every((s) => s.isGranted);
    if (!mounted) return;
    if (allGranted) {
      showDialog(context: context, builder: (ctx) => DeviceScannerDialog(
        scanType: ScanType.wifi,
        onDeviceSelected: (device) { Navigator.pop(ctx); if (mounted) { setState(() {}); _showSuccessSnackBar('Connected to ${device.name}'); } },
      ));
    } else {
      _showErrorSnackBar('Wi-Fi permissions are required');
    }
  }

  Future<void> _disconnect() async {
    try {
      if (_btState == OBDConnectionState.connected) await _btService.disconnect();
      if (_wifiState == WiFiOBDConnectionState.connected) _wifiService.disconnectFromNetwork();
      if (mounted) { setState(() { _connectedDeviceName = ''; _connectionType = ''; }); _showSuccessSnackBar('Disconnected'); }
    } catch (e) { _showErrorSnackBar('Disconnect failed: $e'); }
  }

  // ====================== VEHICLE MANAGER ======================
  void _showVehicleManager() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => _VehicleManagerSheet(
        vehicles: _vehicles, selectedVehicle: _selectedVehicle,
        onVehiclesChanged: () => _loadVehicles(),
        vehicleService: _vehicleService,
      ),
    );
  }

  // ====================== SNACKBARS ======================
  void _showSuccessSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [const Icon(Icons.check_circle_outline, color: Colors.white, size: 20), const SizedBox(width: 12), Expanded(child: Text(msg, style: GoogleFonts.spaceGrotesk(fontSize: 14)))]),
      backgroundColor: Colors.green.withValues(alpha: 0.9), behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16), duration: const Duration(seconds: 2),
    ));
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [const Icon(Icons.error_outline, color: Colors.white, size: 20), const SizedBox(width: 12), Expanded(child: Text(msg, style: GoogleFonts.spaceGrotesk(fontSize: 14)))]),
      backgroundColor: Colors.redAccent.withValues(alpha: 0.9), behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), margin: const EdgeInsets.all(16), duration: const Duration(seconds: 3),
    ));
  }
}

// ====================== VEHICLE MANAGER BOTTOM SHEET ======================
class _VehicleManagerSheet extends StatefulWidget {
  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final VoidCallback onVehiclesChanged;
  final VehicleService vehicleService;
  const _VehicleManagerSheet({required this.vehicles, this.selectedVehicle, required this.onVehiclesChanged, required this.vehicleService});
  @override
  State<_VehicleManagerSheet> createState() => _VehicleManagerSheetState();
}

class _VehicleManagerSheetState extends State<_VehicleManagerSheet> {
  late List<Vehicle> _vehicles;
  bool _showAddForm = false;
  String? _selBrand, _selModel, _nickname;
  int? _selYear;
  final _nicknameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vehicles = List.from(widget.vehicles);
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final v = await widget.vehicleService.getAllVehicles();
    if (mounted) setState(() => _vehicles = v);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85, maxChildSize: 0.95, minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.midnightBlue,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          // Handle
          Padding(padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.glassBorder, borderRadius: BorderRadius.circular(2)))),
          // Title
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Manage Vehicles', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
              GestureDetector(
                onTap: () => setState(() { _showAddForm = !_showAddForm; _resetForm(); }),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: _showAddForm ? null : const LinearGradient(colors: [AppTheme.neonBlue, AppTheme.neonCyan]),
                    color: _showAddForm ? AppTheme.charcoal : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_showAddForm ? Icons.close : Icons.add, color: _showAddForm ? Colors.white : Colors.black, size: 22),
                ),
              ),
            ])),
          const SizedBox(height: 16),
          Expanded(child: SingleChildScrollView(controller: scrollCtrl, child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              if (_showAddForm) _buildAddVehicleForm(),
              if (_vehicles.isEmpty && !_showAddForm) _buildEmptyState(),
              ..._vehicles.map((v) => _buildVehicleTile(v)),
              const SizedBox(height: 40),
            ]),
          ))),
        ]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(children: [
        Icon(Icons.directions_car_outlined, size: 60, color: AppTheme.textMuted),
        const SizedBox(height: 16),
        Text('No Vehicles', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        Text('Tap + to add your first vehicle', style: GoogleFonts.spaceGrotesk(fontSize: 14, color: AppTheme.textMuted), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildAddVehicleForm() {
    return Container(
      padding: const EdgeInsets.all(20), margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppTheme.charcoal, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Add Vehicle', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 16),
        _buildDropdown<String>(label: 'Brand', value: _selBrand, items: VehicleService.brands, onChanged: (v) => setState(() { _selBrand = v; _selModel = null; })),
        const SizedBox(height: 12),
        _buildDropdown<String>(label: 'Model', value: _selModel, items: _selBrand != null ? VehicleService.getModelsForBrand(_selBrand!) : [], onChanged: (v) => setState(() => _selModel = v)),
        const SizedBox(height: 12),
        _buildDropdown<int>(label: 'Year', value: _selYear, items: VehicleService.years, onChanged: (v) => setState(() => _selYear = v)),
        const SizedBox(height: 12),
        TextField(
          controller: _nicknameCtrl,
          style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Nickname (optional)', hintStyle: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted, fontSize: 15),
            filled: true, fillColor: AppTheme.midnightBlue,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.glassBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.glassBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.neonCyan, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _saveVehicle,
          child: Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: (_selBrand != null && _selModel != null && _selYear != null)
                  ? const LinearGradient(colors: [AppTheme.neonBlue, AppTheme.neonCyan]) : null,
              color: (_selBrand == null || _selModel == null || _selYear == null) ? AppTheme.graphite : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text('Save Vehicle', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700,
              color: (_selBrand != null && _selModel != null && _selYear != null) ? Colors.black : AppTheme.textMuted))),
          ),
        ),
      ]),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildDropdown<T>({required String label, T? value, required List<T> items, required ValueChanged<T?> onChanged}) {
    return DropdownButtonFormField<T>(
      value: value, isExpanded: true,
      dropdownColor: AppTheme.charcoal,
      style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label, labelStyle: GoogleFonts.spaceGrotesk(color: AppTheme.textMuted, fontSize: 14),
        filled: true, fillColor: AppTheme.midnightBlue,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.glassBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.glassBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.neonCyan, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: items.map((e) => DropdownMenuItem<T>(value: e, child: Text('$e'))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildVehicleTile(Vehicle v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: v.isSelected ? AppTheme.neonBlue.withValues(alpha: 0.1) : AppTheme.charcoal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: v.isSelected ? AppTheme.neonBlue.withValues(alpha: 0.4) : AppTheme.glassBorder),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.neonBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.directions_car, color: v.isSelected ? AppTheme.neonCyan : AppTheme.neonBlue, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(v.displayName, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
          Text('${v.brand} ${v.model} · ${v.year}', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppTheme.textMuted)),
        ])),
        if (v.isSelected)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.neonCyan.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
            child: Text('ACTIVE', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.neonCyan, letterSpacing: 1)),
          )
        else ...[
          GestureDetector(
            onTap: () async { await widget.vehicleService.selectVehicle(v.id!); await _loadVehicles(); widget.onVehiclesChanged(); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(border: Border.all(color: AppTheme.glassBorder), borderRadius: BorderRadius.circular(8)),
              child: Text('Select', style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async { await widget.vehicleService.deleteVehicle(v.id!); await _loadVehicles(); widget.onVehiclesChanged(); },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
            ),
          ),
        ],
      ]),
    );
  }

  Future<void> _saveVehicle() async {
    if (_selBrand == null || _selModel == null || _selYear == null) return;
    final vehicle = Vehicle(
      brand: _selBrand!,
      model: _selModel!,
      year: _selYear!,
      nickname: _nicknameCtrl.text.isNotEmpty ? _nicknameCtrl.text : null,
      isSelected: _vehicles.isEmpty,
    );
    await widget.vehicleService.addVehicle(vehicle);
    _resetForm();
    await _loadVehicles();
    widget.onVehiclesChanged();
    setState(() => _showAddForm = false);
  }

  void _resetForm() {
    _selBrand = null; _selModel = null; _selYear = null;
    _nicknameCtrl.clear();
  }
}
