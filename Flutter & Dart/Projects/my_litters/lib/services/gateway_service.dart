import 'api_client.dart';

/// Result of a gateway charge (mirrors the backend's Tap-shaped response).
class GatewayCharge {
  final String id;
  final String status; // INITIATED | CAPTURED | DECLINED
  final String method;
  final double amount;
  final String currency;
  final bool simulated;

  const GatewayCharge({
    required this.id,
    required this.status,
    required this.method,
    required this.amount,
    required this.currency,
    required this.simulated,
  });

  bool get isCaptured => status == 'CAPTURED';

  factory GatewayCharge.fromJson(Map<String, dynamic> j) => GatewayCharge(
        id: (j['id'] ?? '').toString(),
        status: (j['status'] ?? '').toString(),
        method: (j['method'] ?? 'src_all').toString(),
        amount: double.tryParse('${j['amount'] ?? 0}') ?? 0.0,
        currency: (j['currency'] ?? 'SAR').toString(),
        simulated: j['simulated'] == true,
      );
}

/// Talks to the backend payment-gateway endpoints. These are Tap-shaped but
/// simulated server-side, so no real charge occurs until Tap keys are added.
class GatewayService {
  GatewayService([ApiClient? client]) : _api = client ?? ApiClient();
  final ApiClient _api;

  Future<GatewayCharge> createCharge({
    required double amount,
    String method = 'src_all',
    String currency = 'SAR',
    Map<String, dynamic>? metadata,
  }) async {
    final data = await _api.post('/api/payments/gateway/charge', body: {
      'amount': amount,
      'method': method,
      'currency': currency,
      if (metadata != null) 'metadata': metadata,
    });
    return GatewayCharge.fromJson((data as Map).cast<String, dynamic>());
  }

  Future<GatewayCharge> confirmCharge({
    required String chargeId,
    bool approve = true,
    String? method,
  }) async {
    final data = await _api.post('/api/payments/gateway/$chargeId/confirm',
        body: {'approve': approve, if (method != null) 'method': method});
    return GatewayCharge.fromJson((data as Map).cast<String, dynamic>());
  }
}
