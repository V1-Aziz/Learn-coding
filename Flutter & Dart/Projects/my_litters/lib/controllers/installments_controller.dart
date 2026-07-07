import '../models/installment.dart';
import '../services/installment_service.dart';

class InstallmentsController {
  final InstallmentService _service = InstallmentService();

  Future<List<InstallmentPlan>> getPlans() => _service.listPlans();

  Future<void> payInstallment(String installmentId) =>
      _service.payInstallment(installmentId);
}
