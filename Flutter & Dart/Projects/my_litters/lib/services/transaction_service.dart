import '../models/fuel_transaction.dart';
import 'api_client.dart';

class TransactionService {
  TransactionService([ApiClient? client]) : _api = client ?? ApiClient();
  final ApiClient _api;

  /// Lists the current user's transaction history (most recent first).
  Future<List<FuelTransaction>> list() async {
    final data = await _api.get('/api/transactions') as List<dynamic>;
    return data
        .map((j) => FuelTransaction.fromJson((j as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Authorizes an NFC-tap transaction. Caller must be a staff/admin user.
  /// Returns the resulting transaction (approved or declined). The endpoint
  /// returns 200 on decline and 201 on approval — both unwrap the same shape.
  Future<FuelTransaction> authorize({
    required String cardUid,
    required double liters,
    required String fuelType,
    String? stationId,
    String? vehicleId,
  }) async {
    final data = await _api.post('/api/transactions/authorize', body: {
      'cardUid': cardUid,
      'liters': liters,
      'fuelType': fuelType,
      if (stationId != null) 'stationId': stationId,
      if (vehicleId != null) 'vehicleId': vehicleId,
    });
    return FuelTransaction.fromJson((data as Map).cast<String, dynamic>());
  }
}
