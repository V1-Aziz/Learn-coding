import '../models/vehicle.dart';
import 'api_client.dart';

class VehicleService {
  VehicleService([ApiClient? client]) : _api = client ?? ApiClient();
  final ApiClient _api;

  Future<List<Vehicle>> list() async {
    final data = await _api.get('/api/vehicles') as List<dynamic>;
    return data
        .map((j) => Vehicle.fromJson((j as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<Vehicle> create({
    required String plateNumber,
    String? make,
    String? model,
    int? year,
    required String fuelType,
  }) async {
    final data = await _api.post('/api/vehicles', body: {
      'plateNumber': plateNumber,
      if (make != null && make.isNotEmpty) 'make': make,
      if (model != null && model.isNotEmpty) 'model': model,
      if (year != null) 'year': year,
      'fuelType': fuelType,
    });
    return Vehicle.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<void> remove(String vehicleId) async {
    await _api.delete('/api/vehicles/$vehicleId');
  }
}
