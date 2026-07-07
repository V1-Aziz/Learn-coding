/// Physical NFC card linked to a user.
/// Backed by the `cards` table on the server.
class FuelCard {
  final String id;
  final String cardUid;
  final String? label;
  final String status; // active | blocked | lost
  final DateTime? linkedAt;

  const FuelCard({
    required this.id,
    required this.cardUid,
    this.label,
    this.status = 'active',
    this.linkedAt,
  });

  factory FuelCard.fromJson(Map<String, dynamic> json) => FuelCard(
        id: json['id'] as String? ?? '',
        cardUid: json['cardUid'] as String? ?? '',
        label: json['label'] as String?,
        status: json['status'] as String? ?? 'active',
        linkedAt: json['linkedAt'] is String
            ? DateTime.tryParse(json['linkedAt'] as String)
            : null,
      );
}
