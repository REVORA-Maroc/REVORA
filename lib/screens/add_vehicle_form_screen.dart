import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'confirm_vehicle_screen.dart';

/// Premium Add Vehicle Form Screen
/// Tesla-style futuristic design for vehicle information input
class AddVehicleFormScreen extends StatefulWidget {
  const AddVehicleFormScreen({super.key});

  @override
  State<AddVehicleFormScreen> createState() => _AddVehicleFormScreenState();
}

class _AddVehicleFormScreenState extends State<AddVehicleFormScreen> {
  final _brandController = TextEditingController();
  String? _selectedModel;
  String? _selectedYear;
  String _selectedFuelType = 'Gasoline';

  final List<String> _models = ['Model 3', 'Model S', 'Model X', 'Model Y'];
  final List<String> _years = List.generate(30, (index) => (2025 - index).toString());

  @override
  void dispose() {
    _brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepSpace,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.darkBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Progress indicator
              _buildProgressIndicator(),

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section title
                      Text(
                        'Vehicle Information',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 100))
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 8),

                      Text(
                        'Provide the basic details to start your listing.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 200)),

                      const SizedBox(height: 32),

                      // Brand field
                      _buildLabel('Brand'),
                      const SizedBox(height: 8),
                      _buildBrandSearchField()
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 300))
                          .slideX(begin: -0.1, end: 0),

                      const SizedBox(height: 24),

                      // Model field
                      _buildLabel('Model'),
                      const SizedBox(height: 8),
                      _buildModelDropdown()
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 400))
                          .slideX(begin: -0.1, end: 0),

                      const SizedBox(height: 24),

                      // Year field
                      _buildLabel('Year'),
                      const SizedBox(height: 8),
                      _buildYearDropdown()
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 500))
                          .slideX(begin: -0.1, end: 0),

                      const SizedBox(height: 24),

                      // Fuel Type
                      _buildLabel('Fuel Type'),
                      const SizedBox(height: 12),
                      _buildFuelTypeSelector()
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 600))
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 32),

                      // Car illustration
                      _buildCarIllustration()
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 700))
                          .scale(delay: const Duration(milliseconds: 700)),

                      const SizedBox(height: 32),

                      // Continue button
                      _buildContinueButton(context)
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 800))
                          .scale(delay: const Duration(milliseconds: 800)),

                      const SizedBox(height: 16),

                      // Save for later
                      _buildSaveForLaterButton()
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 900)),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Add Car',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step 1 of 4',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neonBlue,
                ),
              ),
              Text(
                '25% Complete',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.25,
              minHeight: 6,
              backgroundColor: AppTheme.glassBorder.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildBrandSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.glassBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _brandController,
        style: GoogleFonts.inter(
          fontSize: 15,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: 'Search or select brand',
          hintStyle: GoogleFonts.inter(
            fontSize: 15,
            color: AppTheme.textMuted,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppTheme.textMuted,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildModelDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.glassBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedModel,
          hint: Text(
            'Select model',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.textMuted,
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.textMuted,
          ),
          dropdownColor: const Color(0xFF1A1F2E),
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.white,
          ),
          items: _models.map((String model) {
            return DropdownMenuItem<String>(
              value: model,
              child: Text(model),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedModel = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildYearDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.glassBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedYear,
          hint: Row(
            children: [
              Expanded(
                child: Text(
                  'Select year',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              Icon(
                Icons.calendar_today,
                color: AppTheme.textMuted,
                size: 18,
              ),
            ],
          ),
          isExpanded: true,
          icon: const SizedBox.shrink(),
          dropdownColor: const Color(0xFF1A1F2E),
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.white,
          ),
          items: _years.map((String year) {
            return DropdownMenuItem<String>(
              value: year,
              child: Text(year),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedYear = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildFuelTypeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildFuelTypeChip('Gasoline', Icons.local_gas_station),
        _buildFuelTypeChip('Diesel', Icons.oil_barrel),
        _buildFuelTypeChip('Hybrid', Icons.electric_bolt),
        _buildFuelTypeChip('Electric', Icons.electric_car),
      ],
    );
  }

  Widget _buildFuelTypeChip(String type, IconData icon) {
    final isSelected = _selectedFuelType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFuelType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.neonBlue.withValues(alpha: 0.15)
              : const Color(0xFF1A1F2E).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.neonBlue.withValues(alpha: 0.5)
                : AppTheme.glassBorder.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.neonBlue : AppTheme.textMuted,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              type,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.neonBlue : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarIllustration() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.glassBorder.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.directions_car,
          size: 80,
          color: AppTheme.textMuted.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ConfirmVehicleScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.neonBlue, AppTheme.neonCyan],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonBlue.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          'Continue',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveForLaterButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Text(
          'Save for later',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
