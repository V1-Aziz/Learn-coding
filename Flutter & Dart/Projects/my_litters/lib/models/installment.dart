/// One scheduled payment within a BNPL [InstallmentPlan].
class Installment {
  final String id;
  final int seq;
  final double amount;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final String status; // 'pending' | 'paid'

  const Installment({
    required this.id,
    required this.seq,
    required this.amount,
    required this.dueDate,
    required this.paidAt,
    required this.status,
  });

  factory Installment.fromJson(Map<String, dynamic> json) {
    return Installment(
      id: (json['id'] ?? '').toString(),
      seq: json['seq'] is int
          ? json['seq'] as int
          : int.tryParse('${json['seq'] ?? 0}') ?? 0,
      amount: double.tryParse('${json['amount'] ?? 0}') ?? 0.0,
      dueDate: DateTime.tryParse('${json['dueDate'] ?? ''}'),
      paidAt: DateTime.tryParse('${json['paidAt'] ?? ''}'),
      status: (json['status'] ?? 'pending').toString(),
    );
  }

  bool get isPaid => status == 'paid';
}

/// A BNPL agreement: a plan purchase financed over [months] installments.
class InstallmentPlan {
  final String id;
  final double totalAmount;
  final int months;
  final String status; // 'active' | 'completed' | 'canceled'
  final DateTime? createdAt;
  final List<Installment> installments;

  /// Derived, from the included subscription→plan (may be empty if absent).
  final String planName;
  final String gradeShort;

  const InstallmentPlan({
    required this.id,
    required this.totalAmount,
    required this.months,
    required this.status,
    required this.createdAt,
    required this.installments,
    required this.planName,
    required this.gradeShort,
  });

  factory InstallmentPlan.fromJson(Map<String, dynamic> json) {
    final rawInstallments = (json['installments'] as List?) ?? const [];
    final sub = (json['subscription'] as Map?)?.cast<String, dynamic>();
    final plan = (sub?['plan'] as Map?)?.cast<String, dynamic>();
    final fuelType = (plan?['fuelType'] ?? '').toString();

    return InstallmentPlan(
      id: (json['id'] ?? '').toString(),
      totalAmount: double.tryParse('${json['totalAmount'] ?? 0}') ?? 0.0,
      months: json['months'] is int
          ? json['months'] as int
          : int.tryParse('${json['months'] ?? 1}') ?? 1,
      status: (json['status'] ?? 'active').toString(),
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
      installments: rawInstallments
          .map((j) => Installment.fromJson((j as Map).cast<String, dynamic>()))
          .toList(),
      planName: (plan?['name'] ?? '').toString(),
      gradeShort: _gradeShort(fuelType),
    );
  }

  static String _gradeShort(String fuelType) {
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

  bool get isCompleted => status == 'completed';

  int get paidCount => installments.where((i) => i.isPaid).length;

  /// The next installment awaiting payment, or null if fully settled.
  Installment? get nextDue {
    for (final i in installments) {
      if (!i.isPaid) return i;
    }
    return null;
  }

  double get remainingAmount => installments
      .where((i) => !i.isPaid)
      .fold<double>(0, (sum, i) => sum + i.amount);
}
