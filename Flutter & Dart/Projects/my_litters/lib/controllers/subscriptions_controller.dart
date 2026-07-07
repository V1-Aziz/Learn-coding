import '../models/installment.dart';
import '../models/subscription_plan.dart';
import '../services/subscription_service.dart';

class SubscriptionsController {
  final SubscriptionService _service = SubscriptionService();

  Future<List<SubscriptionPlan>> getPlans() => _service.listPlans();
  Future<ActiveSubscription?> getActive() => _service.getActive();
  Future<CreditSnapshot?> getCredit() => _service.getCredit();
  Future<ActiveSubscription> subscribe({
    required String planId,
    double? creditLimit,
    int? billingDay,
  }) =>
      _service.subscribe(
        planId: planId,
        creditLimit: creditLimit,
        billingDay: billingDay,
      );

  Future<InstallmentPlan> checkout({
    required String planId,
    required int months,
    int? billingDay,
  }) =>
      _service.checkout(
        planId: planId,
        months: months,
        billingDay: billingDay,
      );
}
