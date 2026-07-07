/// Mirrors the backend `Vehicle` row (Prisma model `Vehicle`).
/// Old code used `manufacturer` / `vin` / `imageIndex` — we keep those
/// as derived getters so existing widgets keep compiling.
class Vehicle {
  final String id;
  final String plateNumber;
  final String? make;
  final String? model;
  final int? year;
  final String fuelType; // 'p91' | 'p95' | 'diesel'
  final DateTime? createdAt;

  const Vehicle({
    required this.id,
    required this.plateNumber,
    this.make,
    this.model,
    this.year,
    required this.fuelType,
    this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: (json['id'] ?? '').toString(),
      plateNumber: (json['plateNumber'] ?? '').toString(),
      make: json['make']?.toString(),
      model: json['model']?.toString(),
      year: json['year'] is int
          ? json['year'] as int
          : int.tryParse('${json['year'] ?? ''}'),
      fuelType: (json['fuelType'] ?? 'p95').toString(),
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'plateNumber': plateNumber,
        if (make != null && make!.isNotEmpty) 'make': make,
        if (model != null && model!.isNotEmpty) 'model': model,
        if (year != null) 'year': year,
        'fuelType': fuelType,
      };

  // ---- Back-compat getters used by older widgets -----------------------
  String get manufacturer => make ?? '—';
  String get vin => '—'; // backend does not store VIN
  int get imageIndex => (plateNumber.hashCode.abs() % 2) + 1;

  String get modelDisplay => model ?? '—';

  /// Friendly fuel-type label, e.g. "Petrol 95".
  String get fuelTypeLabel {
    switch (fuelType) {
      case 'p91':
        return 'Petrol 91';
      case 'p95':
        return 'Petrol 95';
      case 'diesel':
        return 'Diesel';
      default:
        return fuelType.toUpperCase();
    }
  }
}
