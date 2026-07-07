import '../models/vehicle.dart';
import '../services/vehicle_service.dart';

class VehiclesController {
  final VehicleService _service = VehicleService();

  Future<List<Vehicle>> getVehicles() => _service.list();

  Future<Vehicle> addVehicle({
    required String plateNumber,
    String? make,
    String? model,
    int? year,
    required String fuelType,
  }) =>
      _service.create(
        plateNumber: plateNumber,
        make: make,
        model: model,
        year: year,
        fuelType: fuelType,
      );

  Future<void> removeVehicle(String id) => _service.remove(id);
}
