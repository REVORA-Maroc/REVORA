import '../models/vehicle.dart';
import 'database_service.dart';

/// Service for managing vehicles and predefined vehicle data
class VehicleService {
  static VehicleService? _instance;
  final DatabaseService _db = DatabaseService.instance;

  VehicleService._();

  static VehicleService get instance {
    _instance ??= VehicleService._();
    return _instance!;
  }

  /// Predefined vehicle brands and their models
  static final Map<String, List<String>> vehicleData = {
    'Toyota': [
      'Corolla',
      'Camry',
      'Yaris',
      'RAV4',
      'Hilux',
      'Land Cruiser',
      'Prius',
      'C-HR',
      'Supra',
      'Fortuner',
    ],
    'BMW': [
      'Series 1',
      'Series 2',
      'Series 3',
      'Series 4',
      'Series 5',
      'Series 7',
      'X1',
      'X3',
      'X5',
      'X6',
      'Z4',
      'M3',
      'M5',
    ],
    'Mercedes-Benz': [
      'A-Class',
      'B-Class',
      'C-Class',
      'E-Class',
      'S-Class',
      'GLA',
      'GLC',
      'GLE',
      'GLS',
      'CLA',
      'AMG GT',
    ],
    'Audi': [
      'A1',
      'A3',
      'A4',
      'A5',
      'A6',
      'A7',
      'A8',
      'Q3',
      'Q5',
      'Q7',
      'Q8',
      'TT',
      'RS6',
    ],
    'Volkswagen': [
      'Golf',
      'Polo',
      'Passat',
      'Tiguan',
      'T-Roc',
      'Touareg',
      'Arteon',
      'ID.4',
      'ID.3',
      'Jetta',
    ],
    'Ford': [
      'Focus',
      'Fiesta',
      'Mustang',
      'Ranger',
      'Explorer',
      'F-150',
      'Escape',
      'Bronco',
      'Edge',
      'Expedition',
    ],
    'Honda': [
      'Civic',
      'Accord',
      'CR-V',
      'HR-V',
      'Jazz',
      'City',
      'Pilot',
      'Odyssey',
      'NSX',
    ],
    'Hyundai': [
      'Elantra',
      'Tucson',
      'Santa Fe',
      'Sonata',
      'Kona',
      'i10',
      'i20',
      'i30',
      'Ioniq 5',
      'Palisade',
    ],
    'Kia': [
      'Sportage',
      'Seltos',
      'Cerato',
      'Sorento',
      'Carnival',
      'Rio',
      'Stinger',
      'EV6',
      'Picanto',
    ],
    'Nissan': [
      'Altima',
      'Sentra',
      'Rogue',
      'Pathfinder',
      'Frontier',
      'Maxima',
      'Kicks',
      'Qashqai',
      'X-Trail',
      'Leaf',
    ],
    'Chevrolet': [
      'Malibu',
      'Camaro',
      'Corvette',
      'Silverado',
      'Equinox',
      'Tahoe',
      'Traverse',
      'Blazer',
      'Spark',
    ],
    'Peugeot': [
      '208',
      '308',
      '408',
      '508',
      '2008',
      '3008',
      '5008',
      'Partner',
      'Rifter',
    ],
    'Renault': [
      'Clio',
      'Megane',
      'Captur',
      'Kadjar',
      'Scenic',
      'Talisman',
      'Duster',
      'Koleos',
      'Zoe',
    ],
    'Dacia': [
      'Sandero',
      'Duster',
      'Logan',
      'Spring',
      'Jogger',
    ],
    'Fiat': [
      '500',
      'Panda',
      'Tipo',
      'Punto',
      'Doblo',
      '500X',
      '500L',
    ],
    'Tesla': [
      'Model 3',
      'Model Y',
      'Model S',
      'Model X',
      'Cybertruck',
    ],
    'Porsche': [
      'Cayenne',
      'Macan',
      'Panamera',
      '911',
      'Taycan',
      'Boxster',
      'Cayman',
    ],
    'Volvo': [
      'XC40',
      'XC60',
      'XC90',
      'S60',
      'S90',
      'V60',
      'V90',
      'C40',
    ],
    'Mazda': [
      'Mazda3',
      'Mazda6',
      'CX-3',
      'CX-5',
      'CX-30',
      'CX-9',
      'MX-5',
    ],
    'Subaru': [
      'Impreza',
      'Forester',
      'Outback',
      'WRX',
      'BRZ',
      'Crosstrek',
      'Legacy',
    ],
  };

  /// Get sorted list of brand names
  static List<String> get brands {
    final keys = vehicleData.keys.toList();
    keys.sort();
    return keys;
  }

  /// Get models for a specific brand
  static List<String> getModelsForBrand(String brand) {
    return vehicleData[brand] ?? [];
  }

  /// Generate year range (2000 to current year + 1)
  static List<int> get years {
    final currentYear = DateTime.now().year;
    return List.generate(currentYear - 1999 + 1, (i) => currentYear + 1 - i);
  }

  // ============== Database operations via DatabaseService ==============

  Future<List<Vehicle>> getAllVehicles() => _db.getAllVehicles();
  Future<Vehicle?> getSelectedVehicle() => _db.getSelectedVehicle();
  Future<int> addVehicle(Vehicle vehicle) => _db.addVehicle(vehicle);
  Future<void> updateVehicle(Vehicle vehicle) => _db.updateVehicle(vehicle);
  Future<bool> deleteVehicle(int id) => _db.deleteVehicle(id);
  Future<void> selectVehicle(int vehicleId) => _db.selectVehicle(vehicleId);
}
