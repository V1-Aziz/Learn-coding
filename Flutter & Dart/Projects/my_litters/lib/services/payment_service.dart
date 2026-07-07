import '../models/payment.dart';
import 'api_client.dart';

class PaymentService {
  PaymentService([ApiClient? client]) : _api = client ?? ApiClient();
  final ApiClient _api;

  /// Lists the user's invoices (most recent first per backend).
  Future<List<Payment>> listInvoices() async {
    final data =
        await _api.get('/api/payments/invoices') as List<dynamic>;
    return data
        .map((j) => Payment.fromJson((j as Map).cast<String, dynamic>()))
        .toList();
  }

  /// Mocked payment: backend marks invoice paid when total payments
  /// reach invoice.total.
  Future<void> payInvoice({
    required String invoiceId,
    required double amount,
    String method = 'card',
  }) async {
    await _api.post('/api/payments/pay', body: {
      'invoiceId': invoiceId,
      'amount': amount,
      'method': method,
    });
  }
}
