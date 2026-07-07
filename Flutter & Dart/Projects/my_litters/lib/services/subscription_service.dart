import '../models/installment.dart';
import '../models/subscription_plan.dart';
import 'api_client.dart';

class SubscriptionService {
  SubscriptionService([ApiClient? client]) : _api = client ?? ApiClient();
  final ApiClient _api;

  /// Public — no auth required by the backend.
  Future<List<SubscriptionPlan>> listPlans() async {
    final data = await _api.get('/api/subscriptions/plans') as List<dynamic>;
    return data
        .map((j) =>
            SubscriptionPlan.fromJson((j as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Returns null if the user has no active subscription yet.
  Future<ActiveSubscription?> getActive() async {
    final data = await _api.get('/api/subscriptions/active');
    if (data == null) return null;
    return ActiveSubscription.fromJson((data as Map).cast<String, dynamic>());
  }

  /// Returns null if the user has no active subscription.
  Future<CreditSnapshot?> getCredit() async {
    final data = await _api.get('/api/subscriptions/credit');
    if (data == null) return null;
    return CreditSnapshot.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<ActiveSubscription> subscribe({
    required String planId,
    double? creditLimit,
    int? billingDay,
  }) async {
    final data = await _api.post('/api/subscriptions', body: {
      'planId': planId,
      if (creditLimit != null) 'creditLimit': creditLimit,
      if (billingDay != null) 'billingDay': billingDay,
    });
    return ActiveSubscription.fromJson((data as Map).cast<String, dynamic>());
  }

  /// BNPL checkout: subscribe and finance the plan total over [months]
  /// installments (1 = paid in full). The backend settles the first
  /// installment immediately, which activates the subscription. Returns the
  /// created installment plan with its schedule.
  Future<InstallmentPlan> checkout({
    required String planId,
    required int months,
    int? billingDay,
  }) async {
    final data = await _api.post('/api/subscriptions/checkout', body: {
      'planId': planId,
      'months': months,
      if (billingDay != null) 'billingDay': billingDay,
    });
    final map = (data as Map).cast<String, dynamic>();
    return InstallmentPlan.fromJson(
        ((map['installmentPlan'] as Map?) ?? const {}).cast<String, dynamic>());
  }
}
