import '../services/dashboard_service.dart';

class DashboardController {
  final DashboardService _service = DashboardService();

  Future<DashboardSummary> getSummary() => _service.getSummary();
}
