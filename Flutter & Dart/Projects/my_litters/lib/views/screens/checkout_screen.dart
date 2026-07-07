import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/subscriptions_controller.dart';
import '../../models/subscription_plan.dart';
import '../../services/api_client.dart';
import '../../utils/app_colors.dart';
import 'payment_gateway_sheet.dart';

/// Simulated BNPL checkout. The subscription is NOT active until the user
/// taps "Pay". The user can pay the plan total in full or split it over 2-4
/// monthly installments; the first installment is settled here, which
/// activates the plan. On success we pop back to the caller with `true`.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.plan});

  final SubscriptionPlan plan;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _controller = SubscriptionsController();
  final _num = NumberFormat('#,##0.00');
  final _dateFmt = DateFormat('MMM d');

  /// 1 = pay in full; 2/3/4 = split into that many monthly installments.
  int _months = 1;
  bool _paying = false;

  static const _monthOptions = [1, 2, 3, 4];

  Color get _gradeColor {
    switch (widget.plan.fuelType) {
      case 'p91':
        return AppColors.fuelGreen;
      case 'diesel':
        return AppColors.fuelAmber;
      case 'p95':
      default:
        return AppColors.fuelRed;
    }
  }

  double get _fuelTotal =>
      widget.plan.pricePerLiter * widget.plan.monthlyLitersLimit;

  /// Must match the backend's planTotal: fuel value + monthly fee.
  double get _total => _fuelTotal + widget.plan.monthlyFee;

  /// Split [_total] into [_months] installments, mirroring the backend:
  /// equal amounts at 3-dp, with any rounding remainder on the first one.
  List<double> get _installments {
    final totalMilli = (_total * 1000).round();
    final base = totalMilli ~/ _months;
    final remainder = totalMilli - base * _months;
    return List.generate(
      _months,
      (i) => (base + (i == 0 ? remainder : 0)) / 1000.0,
    );
  }

  double get _dueNow => _installments.first;

  Future<void> _pay() async {
    // Collect payment through the (simulated) gateway first; the subscription
    // is only activated once the charge is captured.
    final paid = await showPaymentGateway(
      context,
      amount: _dueNow,
      metadata: {'planId': widget.plan.id, 'months': _months},
    );
    if (!mounted || paid != true) return;

    setState(() => _paying = true);
    try {
      await _controller.checkout(planId: widget.plan.id, months: _months);
      if (!mounted) return;
      final msg = _months == 1
          ? 'Payment successful — ${widget.plan.name} ${widget.plan.gradeShort} is now active'
          : 'First installment paid — ${widget.plan.name} ${widget.plan.gradeShort} is now active';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _paying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _paying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.subscriptionBackground,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _summaryCard(),
                    const SizedBox(height: 16),
                    _planSelector(),
                    const SizedBox(height: 16),
                    _breakdown(),
                    if (_months > 1) ...[
                      const SizedBox(height: 16),
                      _schedule(),
                    ],
                    const SizedBox(height: 16),
                    _disclaimer(),
                  ],
                ),
              ),
            ),
            _payBar(),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard() {
    final plan = widget.plan;
    return _card(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _gradeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              plan.gradeShort,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${plan.name} Plan',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${plan.fuelTypeLabel} · ${plan.monthlyLitersLimit} L / month',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _planSelector() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How do you want to pay?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final m in _monthOptions) ...[
                Expanded(child: _payOption(m)),
                if (m != _monthOptions.last) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _payOption(int m) {
    final selected = _months == m;
    final perMilli = (_total * 1000).round() ~/ m;
    final per = perMilli / 1000.0;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: _paying ? null : () => setState(() => _months = m),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              m == 1 ? 'Full' : '$m mo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                m == 1 ? _num.format(_total) : '${_num.format(per)}/mo',
                style: TextStyle(
                  fontSize: 11,
                  color: selected ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _breakdown() {
    return _card(
      child: Column(
        children: [
          _row(
            '${widget.plan.monthlyLitersLimit} L × ${_num.format(widget.plan.pricePerLiter)} SAR',
            '${_num.format(_fuelTotal)} SAR',
          ),
          if (widget.plan.monthlyFee > 0) ...[
            const SizedBox(height: 10),
            _row('Monthly fee', '${_num.format(widget.plan.monthlyFee)} SAR'),
          ],
          const SizedBox(height: 10),
          _row('Plan total', '${_num.format(_total)} SAR'),
          if (_months > 1) ...[
            const SizedBox(height: 10),
            _row('Split', '$_months payments'),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _row(
            _months == 1 ? 'Total due now' : 'Due now (1st of $_months)',
            '${_num.format(_dueNow)} SAR',
            emphasize: true,
          ),
          if (_months > 1) ...[
            const SizedBox(height: 6),
            _row(
              'Then',
              '${_months - 1} × ${_num.format(_installments[1])} SAR monthly',
              muted: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _schedule() {
    final now = DateTime.now();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment schedule',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _installments.length; i++) ...[
            if (i > 0) const Divider(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: i == 0
                      ? AppColors.success
                      : AppColors.primary.withValues(alpha: 0.12),
                  child: i == 0
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    i == 0
                        ? 'Today'
                        : _dateFmt.format(DateTime(
                            now.year, now.month + i, now.day)),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Text(
                  '${_num.format(_installments[i])} SAR',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: i == 0 ? AppColors.success : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  i == 0 ? 'Paid now' : 'Scheduled',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {bool emphasize = false, bool muted = false}) {
    final style = TextStyle(
      fontSize: emphasize ? 16 : (muted ? 12 : 14),
      fontWeight: emphasize ? FontWeight.bold : FontWeight.w500,
      color: emphasize
          ? Colors.black87
          : (muted ? Colors.grey.shade500 : Colors.grey.shade700),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label, style: style)),
        const SizedBox(width: 12),
        Text(value, style: style),
      ],
    );
  }

  Widget _disclaimer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'This is a simulated payment for demo purposes. No real charge '
            'is made. Your plan activates once the first payment completes; '
            'any remaining installments appear on your Payments page.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _payBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _paying ? null : _pay,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _paying
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Pay ${_num.format(_dueNow)} SAR',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
