/// Mirrors backend `Plan`. Old screens used a different shape so we
/// keep `name`, `recommendation`, and a `fuelPrices` list as derived
/// values for back-compat.
class SubscriptionPlan {
  final String id;
  final String name;
  final String fuelType; // 'p91' | 'p95' | 'diesel'
  final int monthlyLitersLimit;
  final double pricePerLiter;
  final double monthlyFee;
  final bool isActive;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.fuelType,
    required this.monthlyLitersLimit,
    required this.pricePerLiter,
    required this.monthlyFee,
    required this.isActive,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      fuelType: (json['fuelType'] ?? 'p95').toString(),
      monthlyLitersLimit: json['monthlyLitersLimit'] is int
          ? json['monthlyLitersLimit'] as int
          : int.tryParse('${json['monthlyLitersLimit'] ?? 0}') ?? 0,
      pricePerLiter:
          double.tryParse('${json['pricePerLiter'] ?? 0}') ?? 0.0,
      monthlyFee: double.tryParse('${json['monthlyFee'] ?? 0}') ?? 0.0,
      isActive: json['isActive'] != false,
    );
  }

  /// Heuristic recommendation used in the old UI.
  String get recommendation {
    if (monthlyLitersLimit <= 250) {
      return 'Recommended for small cars, sedans and small SUVs';
    }
    if (monthlyLitersLimit <= 450) {
      return 'Recommended for large SUVs and pickup trucks';
    }
    return 'Recommended for large trucks and trailers';
  }

  /// Short grade label for the colored boxes: '91', '95', 'Diesel'.
  String get gradeShort {
    switch (fuelType) {
      case 'p91':
        return '91';
      case 'p95':
        return '95';
      case 'diesel':
        return 'Diesel';
      default:
        return fuelType.toUpperCase();
    }
  }

  /// Friendly fuel-type label for the chip on the card.
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

  /// Estimated monthly cost if the user uses up the entire liter cap.
  double get monthlyCap => pricePerLiter * monthlyLitersLimit + monthlyFee;
}

/// View-model for the user's currently-active subscription.
class ActiveSubscription {
  final String id;
  final String status;
  final double creditLimit;
  final int billingDay;
  final DateTime? startedAt;
  final SubscriptionPlan plan;

  const ActiveSubscription({
    required this.id,
    required this.status,
    required this.creditLimit,
    required this.billingDay,
    required this.startedAt,
    required this.plan,
  });

  factory ActiveSubscription.fromJson(Map<String, dynamic> json) {
    return ActiveSubscription(
      id: (json['id'] ?? '').toString(),
      status: (json['status'] ?? 'active').toString(),
      creditLimit: double.tryParse('${json['creditLimit'] ?? 0}') ?? 0.0,
      billingDay: json['billingDay'] is int
          ? json['billingDay'] as int
          : int.tryParse('${json['billingDay'] ?? 1}') ?? 1,
      startedAt: DateTime.tryParse('${json['startedAt'] ?? ''}'),
      plan: SubscriptionPlan.fromJson(
          ((json['plan'] as Map?) ?? const {}).cast<String, dynamic>()),
    );
  }
}

/// View-model for `/api/subscriptions/credit`.
class CreditSnapshot {
  final String subscriptionId;
  final double creditLimit;
  final double unbilledBalance;
  final double availableCredit;
  final SubscriptionPlan plan;

  const CreditSnapshot({
    required this.subscriptionId,
    required this.creditLimit,
    required this.unbilledBalance,
    required this.availableCredit,
    required this.plan,
  });

  factory CreditSnapshot.fromJson(Map<String, dynamic> json) {
    return CreditSnapshot(
      subscriptionId: (json['subscriptionId'] ?? '').toString(),
      creditLimit: double.tryParse('${json['creditLimit'] ?? 0}') ?? 0.0,
      unbilledBalance:
          double.tryParse('${json['unbilledBalance'] ?? 0}') ?? 0.0,
      availableCredit:
          double.tryParse('${json['availableCredit'] ?? 0}') ?? 0.0,
      plan: SubscriptionPlan.fromJson(
          ((json['plan'] as Map?) ?? const {}).cast<String, dynamic>()),
    );
  }
}
