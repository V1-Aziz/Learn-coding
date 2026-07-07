import '../models/installment.dart';
import 'api_client.dart';

class InstallmentService {
  InstallmentService([ApiClient? client]) : _api = client ?? ApiClient();
  final ApiClient _api;

  /// All of the signed-in user's BNPL plans, most recent first.
  Future<List<InstallmentPlan>> listPlans() async {
    final data = await _api.get('/api/installments') as List<dynamic>;
    return data
        .map((j) =>
            InstallmentPlan.fromJson((j as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Simulate paying a single scheduled installment.
  Future<void> payInstallment(String installmentId) async {
    await _api.post('/api/installments/$installmentId/pay');
  }
}
