import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_client.dart';
import '../../services/gateway_service.dart';
import '../../utils/app_colors.dart';

/// Simulated payment-gateway checkout, shaped like Tap's hosted page. Returns
/// `true` when the (simulated) charge is captured, `false`/`null` otherwise.
///
/// This is the swap point for the real gateway: replace the body with a
/// WebView of the charge's `transactionUrl` and read the result from the
/// signed webhook instead of the local confirm call.
Future<bool?> showPaymentGateway(
  BuildContext context, {
  required double amount,
  Map<String, dynamic>? metadata,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PaymentGatewaySheet(amount: amount, metadata: metadata),
  );
}

class _PaymentMethod {
  const _PaymentMethod(this.id, this.label, this.icon);
  final String id;
  final String label;
  final IconData icon;
}

const _methods = <_PaymentMethod>[
  _PaymentMethod('src_mada', 'Mada', Icons.credit_card),
  _PaymentMethod('src_card', 'Card', Icons.credit_card_outlined),
  _PaymentMethod('src_tamara', 'Tamara', Icons.calendar_month),
  _PaymentMethod('src_tabby', 'Tabby', Icons.calendar_view_week),
];

class _PaymentGatewaySheet extends StatefulWidget {
  const _PaymentGatewaySheet({required this.amount, this.metadata});
  final double amount;
  final Map<String, dynamic>? metadata;

  @override
  State<_PaymentGatewaySheet> createState() => _PaymentGatewaySheetState();
}

class _PaymentGatewaySheetState extends State<_PaymentGatewaySheet> {
  final _service = GatewayService();
  final _money = NumberFormat('#,##0.00');
  String _method = 'src_mada';
  bool _busy = false;
  String? _error;

  Future<void> _pay({required bool approve}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final charge = await _service.createCharge(
        amount: widget.amount,
        method: _method,
        metadata: widget.metadata,
      );
      final result = await _service.confirmCharge(
        chargeId: charge.id,
        approve: approve,
        method: _method,
      );
      if (!mounted) return;
      if (result.isCaptured) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _error = 'Payment declined. Please try another method.');
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              const Text('Secure checkout',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('TEST',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900)),
              ),
              const Spacer(),
              Icon(Icons.lock, size: 18, color: Colors.grey.shade500),
            ],
          ),
          const SizedBox(height: 4),
          Text('Amount due: ${_money.format(widget.amount)} SAR',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          const Text('Payment method',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _methods.map((m) {
              final selected = m.id == _method;
              return ChoiceChip(
                selected: selected,
                onSelected: _busy ? null : (_) => setState(() => _method = m.id),
                avatar: Icon(m.icon,
                    size: 18,
                    color: selected ? Colors.white : AppColors.primary),
                label: Text(m.label),
                labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600),
                selectedColor: AppColors.primary,
                backgroundColor: Colors.grey.shade100,
              );
            }).toList(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _busy ? null : () => _pay(approve: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white)),
                    )
                  : Text('Pay ${_money.format(widget.amount)} SAR',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _busy ? null : () => _pay(approve: false),
            child: Text('Simulate a declined payment',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
