/// One NFC tap recorded by the backend.
/// Status is `approved` (charged against credit), `declined`, or `voided`.
class FuelTransaction {
  final String id;
  final double liters;
  final double pricePerLiter;
  final double totalAmount;
  final String fuelType;
  final String status;
  final String? declineReason;
  final DateTime tappedAt;

  const FuelTransaction({
    required this.id,
    required this.liters,
    required this.pricePerLiter,
    required this.totalAmount,
    required this.fuelType,
    required this.status,
    this.declineReason,
    required this.tappedAt,
  });

  bool get isApproved => status == 'approved';
  bool get isDeclined => status == 'declined';

  factory FuelTransaction.fromJson(Map<String, dynamic> json) => FuelTransaction(
        id: json['id'] as String? ?? '',
        liters: _num(json['liters']),
        pricePerLiter: _num(json['pricePerLiter']),
        totalAmount: _num(json['totalAmount']),
        fuelType: json['fuelType'] as String? ?? '',
        status: json['status'] as String? ?? 'declined',
        declineReason: json['declineReason'] as String?,
        tappedAt: json['tappedAt'] is String
            ? DateTime.tryParse(json['tappedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  static double _num(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}
