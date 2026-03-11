import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../widgets/device_scanner_dialog.dart';

/// Modern Home Screen for Revora
/// Features professional UI with smooth animations
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isConnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepSpace,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Summary Strip
                    _buildSummaryStrip()
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 100))
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 16),

                    // Vehicle Card
                    _buildVehicleCard()
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 200))
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 16),

                    // OBD2 Connection Card
                    _buildConnectionCard()
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 300))
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 16),

                    // Feature Grid
                    _buildFeatureGrid()
                        .animate()
                        .fadeIn(delay: const Duration(milliseconds: 400))
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 100), // Space for bottom nav
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.charcoal.withValues(alpha: 0.7),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and Title with Animation
          Row(
            children: [
              // Animated Logo from assets
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonCyan.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/revora_logo.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppTheme.neonCyan, AppTheme.neonBlue],
                          ),
                        ),
                        child: const Icon(
                          Icons.electric_car,
                          size: 24,
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: const Duration(milliseconds: 400))
                  .scale(delay: const Duration(milliseconds: 100))
                  .then()
                  .shimmer(duration: const Duration(seconds: 2)),

              const SizedBox(width: 12),

              Text(
                'REVORA',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 150))
                  .slideX(begin: -0.2, end: 0),
            ],
          ),

          // Status and Settings
          Row(
            children: [
              // Offline Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.charcoal.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.glassBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'OFFLINE',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Settings Button
              GestureDetector(
                onTap: () {
                  // Navigate to settings
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 200)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.charcoal.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.glassBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Last Scan', '2h ago'),
          Container(
            width: 1,
            height: 32,
            color: AppTheme.glassBorder,
          ),
          _buildSummaryItem('System', 'Healthy', isHighlighted: true),
          Container(
            width: 1,
            height: 32,
            color: AppTheme.glassBorder,
          ),
          _buildSummaryItem('Alerts', '0 Active'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value,
      {bool isHighlighted = false}) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isHighlighted ? AppTheme.neonBlue : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.charcoal,
            AppTheme.midnightBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.neonBlue.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Glow
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.neonBlue.withValues(alpha: 0.1),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tesla Model 3',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Dual Motor Performance',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.neonBlue,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.neonBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ELECTRIC',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.neonBlue,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Car Image
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/images/car.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.charcoal,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.electric_car,
                              size: 80,
                              color: AppTheme.neonBlue.withValues(alpha: 0.5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Manage Vehicle Button
                  GestureDetector(
                    onTap: () {
                      // Navigate to vehicle management
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.neonBlue,
                            AppTheme.neonCyan,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonBlue.withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.edit_road,
                            color: Colors.black,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Manage Vehicle',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: const Duration(milliseconds: 300))
                      .scale(delay: const Duration(milliseconds: 300)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.midnightBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.glassBorder,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          // Bluetooth Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.charcoal,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
              color: _isConnected ? AppTheme.neonCyan : AppTheme.textMuted,
              size: 32,
            ),
          )
              .animate()
              .fadeIn()
              .scale(delay: const Duration(milliseconds: 100)),

          const SizedBox(height: 16),

          // Title
          Text(
            _isConnected ? 'Connected' : 'Not Connected',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _isConnected ? AppTheme.neonCyan : Colors.white,
            ),
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 150)),

          const SizedBox(height: 8),

          // Description
          Text(
            _isConnected
                ? 'Your OBD-II device is connected and ready.'
                : 'Connection required for real-time telemetry and advanced diagnostics.',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 200)),

          const SizedBox(height: 20),

          // Connection Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _requestBluetoothPermission(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.neonBlue,
                          AppTheme.neonCyan,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonBlue.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.bluetooth,
                          color: Colors.black,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Bluetooth',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
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
                  onTap: () => _requestWifiPermission(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.charcoal,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.glassBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Wi-Fi',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 250)),
        ],
      ),
    );
  }

  /// Request Bluetooth permissions and show scanner
  Future<void> _requestBluetoothPermission() async {
    // Store context before async operation
    if (!mounted) return;

    // Request Bluetooth permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (!mounted) return;

    if (allGranted) {
      // Show device scanner dialog
      showDialog(
        context: context,
        builder: (dialogContext) => DeviceScannerDialog(
          scanType: ScanType.bluetooth,
          onDeviceSelected: (device) {
            Navigator.pop(dialogContext);
            if (mounted) {
              setState(() {
                _isConnected = true;
              });
              _showSuccessSnackBar('Connected to ${device.name}');
            }
          },
        ),
      );
    } else {
      _showErrorSnackBar('Bluetooth permissions are required to scan for devices');
    }
  }

  /// Request Wi-Fi permissions and show scanner
  Future<void> _requestWifiPermission() async {
    // Store context before async operation
    if (!mounted) return;

    // Request Wi-Fi and location permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.nearbyWifiDevices,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (!mounted) return;

    if (allGranted) {
      // Show device scanner dialog
      showDialog(
        context: context,
        builder: (dialogContext) => DeviceScannerDialog(
          scanType: ScanType.wifi,
          onDeviceSelected: (device) {
            Navigator.pop(dialogContext);
            if (mounted) {
              setState(() {
                _isConnected = true;
              });
              _showSuccessSnackBar('Connected to ${device.name}');
            }
          },
        ),
      );
    } else {
      _showErrorSnackBar('Location permission is required to scan for Wi-Fi devices');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.spaceGrotesk(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.spaceGrotesk(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Column(
      children: [
        Row(
          children: [
            // Diagnostics Card
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.health_and_safety,
                iconColor: Colors.orange,
                iconBgColor: Colors.orange.withValues(alpha: 0.1),
                title: 'Diagnostics',
                subtitle: 'Check vehicle health & faults',
                onTap: () {
                  // Navigate to diagnostics
                },
              )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 100))
                  .scale(delay: const Duration(milliseconds: 100)),
            ),
            const SizedBox(width: 12),
            // Dashboard Card
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.speed,
                iconColor: AppTheme.neonBlue,
                iconBgColor: AppTheme.neonBlue.withValues(alpha: 0.1),
                title: 'Dashboard',
                subtitle: 'Real-time dynamic clusters',
                onTap: () {
                  // Navigate to dashboard
                },
              )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 200))
                  .scale(delay: const Duration(milliseconds: 200)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Live Data Card (Full Width)
        _buildLiveDataCard()
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 300))
            .slideX(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.charcoal,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.glassBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            )
                .animate()
                .scale(delay: const Duration(milliseconds: 100)),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveDataCard() {
    return GestureDetector(
      onTap: () {
        // Navigate to live data
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.charcoal,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.neonCyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.query_stats,
                color: AppTheme.neonCyan,
                size: 28,
              ),
            )
                .animate()
                .rotate(delay: const Duration(milliseconds: 100)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Data',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sensor values & performance telemetry',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.textMuted,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.charcoal.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: AppTheme.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.build, 'Diag', 1),
            _buildNavItem(Icons.psychology, 'Insights', 2),
            _buildNavItem(Icons.route, 'Trips', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.neonBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.neonBlue : AppTheme.textSecondary,
              size: 24,
              fill: isSelected ? 1.0 : 0.0,
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppTheme.neonBlue : AppTheme.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
