/// Mirrors the backend `Invoice` row plus a few derived view fields the
/// existing payments UI expects (`date`, `amount`, `isPaid`, `isChecked`).
class Payment {
  final String id;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final double subtotal;
  final double monthlyFee;
  final double total;
  final String status; // 'open' | 'due' | 'paid' | 'overdue'

  /// Used by the existing UI's "checkbox" state. Does not round-trip.
  bool isChecked;

  Payment({
    required this.id,
    required this.periodStart,
    required this.periodEnd,
    required this.dueDate,
    required this.paidAt,
    required this.subtotal,
    required this.monthlyFee,
    required this.total,
    required this.status,
    this.isChecked = false,
  });

  /// Convenience used by old UI when constructing a fallback "no upcoming"
  /// Payment object.
  factory Payment.placeholder({String date = '', double amount = 0.0}) {
    return Payment(
      id: '',
      periodStart: null,
      periodEnd: null,
      dueDate: null,
      paidAt: null,
      subtotal: 0,
      monthlyFee: 0,
      total: amount,
      status: 'open',
      isChecked: false,
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: (json['id'] ?? '').toString(),
      periodStart: DateTime.tryParse('${json['periodStart'] ?? ''}'),
      periodEnd: DateTime.tryParse('${json['periodEnd'] ?? ''}'),
      dueDate: DateTime.tryParse('${json['dueDate'] ?? ''}'),
      paidAt: DateTime.tryParse('${json['paidAt'] ?? ''}'),
      subtotal: double.tryParse('${json['subtotal'] ?? 0}') ?? 0.0,
      monthlyFee: double.tryParse('${json['monthlyFee'] ?? 0}') ?? 0.0,
      total: double.tryParse('${json['total'] ?? 0}') ?? 0.0,
      status: (json['status'] ?? 'open').toString(),
      isChecked: (json['status'] == 'paid'),
    );
  }

  bool get isPaid => status == 'paid';
  double get amount => total;

  /// Human-friendly date label used by the existing PaymentCard.
  String get date {
    if (status == 'paid' && paidAt != null) {
      return _formatMonthDay(paidAt!);
    }
    if (dueDate != null) {
      final now = DateTime.now();
      final diff = dueDate!.difference(DateTime(now.year, now.month, now.day));
      final days = diff.inDays;
      if (days == 0) return 'Due today';
      if (days > 0 && days <= 14) return 'Due in $days day${days == 1 ? '' : 's'}';
      if (days < 0) return 'Overdue ${-days}d';
      return 'Due ${_formatMonthDay(dueDate!)}';
    }
    return '—';
  }

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  String _formatMonthDay(DateTime dt) => '${_months[dt.month - 1]} ${dt.day}';
}
