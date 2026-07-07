import '../models/payment.dart';
import '../services/payment_service.dart';

class PaymentsController {
  final PaymentService _service = PaymentService();

  Future<List<Payment>> getPayments() => _service.listInvoices();

  Future<void> payInvoice({
    required String invoiceId,
    required double amount,
    String method = 'card',
  }) =>
      _service.payInvoice(
        invoiceId: invoiceId,
        amount: amount,
        method: method,
      );
}
