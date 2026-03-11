/// Vehicle model for local database storage
class Vehicle {
  int? id;
  String brand;
  String model;
  int year;
  String? nickname;
  bool isSelected;
  DateTime createdAt;

  Vehicle({
    this.id,
    required this.brand,
    required this.model,
    required this.year,
    this.nickname,
    this.isSelected = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Display name - returns nickname if set, otherwise "brand model (year)"
  String get displayName {
    if (nickname != null && nickname!.isNotEmpty) {
      return nickname!;
    }
    return '$brand $model ($year)';
  }

  /// Short display name
  String get shortName {
    if (nickname != null && nickname!.isNotEmpty) {
      return nickname!;
    }
    return '$brand $model';
  }

  /// Convert to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'nickname': nickname,
      'isSelected': isSelected ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create a Vehicle from a database Map
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      brand: map['brand'] as String,
      model: map['model'] as String,
      year: map['year'] as int,
      nickname: map['nickname'] as String?,
      isSelected: (map['isSelected'] as int?) == 1,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
