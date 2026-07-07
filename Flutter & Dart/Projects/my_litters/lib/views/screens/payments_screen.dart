import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/installments_controller.dart';
import '../../controllers/payments_controller.dart';
import '../../models/installment.dart';
import '../../models/payment.dart';
import '../../services/api_client.dart';
import '../../services/notification_service.dart';
import '../../utils/app_colors.dart';
import '../widgets/payment_card.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _controller = PaymentsController();
  final _installmentsController = InstallmentsController();
  final _money = NumberFormat.simpleCurrency(name: 'SAR', decimalDigits: 2);
  final _dateFmt = DateFormat('MMM d');
  late Future<_PaymentsData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _load();
  }

  Future<_PaymentsData> _load() async {
    final results = await Future.wait<dynamic>([
      _controller.getPayments(),
      _installmentsController.getPlans().catchError((_) => <InstallmentPlan>[]),
    ]);
    final data = _PaymentsData(
      invoices: (results[0] as List).cast<Payment>(),
      plans: (results[1] as List).cast<InstallmentPlan>(),
    );
    // Keep local reminders in sync with the latest schedule.
    NotificationService.syncInstallmentReminders(data.plans);
    return data;
  }

  void _refresh() => setState(() => _dataFuture = _load());

  Future<void> _payInstallment(Installment inst) async {
    try {
      await _installmentsController.payInstallment(inst.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Paid ${_money.format(inst.amount)}')),
      );
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  Future<void> _payNext(Payment invoice) async {
    if (invoice.id.isEmpty) return;
    try {
      await _controller.payInvoice(
        invoiceId: invoice.id,
        amount: invoice.amount,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Paid ${_money.format(invoice.amount)}')),
      );
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<_PaymentsData>(
          future: _dataFuture,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return _ErrorView(
                message: snap.error.toString(),
                onRetry: _refresh,
              );
            }
            final invoices = snap.data?.invoices ?? const <Payment>[];
            final plans = snap.data?.plans ?? const <InstallmentPlan>[];
            final activePlans =
                plans.where((p) => !p.isCompleted).toList();
            final completedPlans =
                plans.where((p) => p.isCompleted).toList();
            final hasHistory =
                invoices.isNotEmpty || completedPlans.isNotEmpty;
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 0.0,
                  floating: true,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  title: const Text('Payments',
                      style: TextStyle(color: Colors.white)),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummarySection(invoices, plans),
                        const SizedBox(height: 24),
                        _buildInstallmentsSection(activePlans),
                        const Text(
                          'Payment History',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (!hasHistory)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'No invoices yet — your first one will appear after a tap.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else ...[
                          ...completedPlans.map((p) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _completedPlanTile(p),
                              )),
                          ...invoices.map((p) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: PaymentCard(payment: p),
                              )),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummarySection(
      List<Payment> invoices, List<InstallmentPlan> plans) {
    // Total paid = settled invoices + settled installments.
    final paidInvoices = invoices
        .where((p) => p.isPaid)
        .fold<double>(0, (sum, p) => sum + p.amount);
    final paidInstallments = plans
        .expand((p) => p.installments)
        .where((i) => i.isPaid)
        .fold<double>(0, (sum, i) => sum + i.amount);
    final totalPaid = paidInvoices + paidInstallments;

    // Next due = soonest pending installment or unpaid invoice.
    Installment? nextInst;
    for (final p in plans) {
      final due = p.nextDue;
      if (due == null || due.dueDate == null) continue;
      if (nextInst?.dueDate == null ||
          due.dueDate!.isBefore(nextInst!.dueDate!)) {
        nextInst = due;
      }
    }
    Payment? nextInvoice;
    for (final p in invoices.where((p) => !p.isPaid)) {
      if (p.dueDate == null) continue;
      if (nextInvoice?.dueDate == null ||
          p.dueDate!.isBefore(nextInvoice!.dueDate!)) {
        nextInvoice = p;
      }
    }

    // Decide which is sooner; installments win ties.
    double nextAmount = 0;
    VoidCallback? onPay;
    if (nextInst != null &&
        (nextInvoice?.dueDate == null ||
            !nextInvoice!.dueDate!.isBefore(nextInst.dueDate!))) {
      nextAmount = nextInst.amount;
      final inst = nextInst;
      onPay = () => _payInstallment(inst);
    } else if (nextInvoice != null) {
      nextAmount = nextInvoice.amount;
      final inv = nextInvoice;
      onPay = () => _payNext(inv);
    }
    final hasUnpaid = onPay != null;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryCard(
                title: 'Total Paid',
                amount: totalPaid,
                icon: Icons.check_circle,
              ),
              _buildSummaryCard(
                title: 'Next Payment',
                amount: nextAmount,
                icon: Icons.calendar_today,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                hasUnpaid
                    ? 'Pay ${_money.format(nextAmount)} Now'
                    : 'No outstanding payments',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// BNPL installment plans. Hidden entirely when the user has none.
  Widget _buildInstallmentsSection(List<InstallmentPlan> plans) {
    if (plans.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Plan Installments',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...plans.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _installmentPlanCard(p),
            )),
        const SizedBox(height: 24),
      ],
    );
  }

  /// A finished plan, shown collapsed in Payment History. Tap to expand
  /// the per-installment breakdown.
  Widget _completedPlanTile(InstallmentPlan plan) {
    final title = [plan.planName, plan.gradeShort]
        .where((s) => s.isNotEmpty)
        .join(' ');
    final paidOn = plan.installments
        .where((i) => i.paidAt != null)
        .map((i) => i.paidAt!)
        .fold<DateTime?>(null, (latest, d) {
      if (latest == null || d.isAfter(latest)) return d;
      return latest;
    });
    final subtitle = paidOn != null
        ? '${_money.format(plan.totalAmount)} · Settled ${_dateFmt.format(paidOn)}'
        : '${_money.format(plan.totalAmount)} · Settled';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 12),
          leading: Icon(Icons.check_circle, color: Colors.green.shade600),
          title: Text(
            title.isEmpty ? 'Plan' : title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          children: plan.installments.map(_installmentRow).toList(),
        ),
      ),
    );
  }

  Widget _installmentPlanCard(InstallmentPlan plan) {
    final next = plan.nextDue;
    final title = [plan.planName, plan.gradeShort]
        .where((s) => s.isNotEmpty)
        .join(' ');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.isEmpty ? 'Plan' : title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              _statusBadge(plan),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            plan.months == 1
                ? 'Paid in full · ${_money.format(plan.totalAmount)}'
                : '${plan.paidCount} of ${plan.months} payments · '
                    '${_money.format(plan.totalAmount)} total',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          ...plan.installments.map(_installmentRow),
          if (next != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => _payInstallment(next),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Pay installment ${next.seq} · ${_money.format(next.amount)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _installmentRow(Installment inst) {
    final due = inst.dueDate;
    final label = inst.isPaid
        ? (inst.paidAt != null ? 'Paid ${_dateFmt.format(inst.paidAt!)}' : 'Paid')
        : (due != null ? 'Due ${_dateFmt.format(due)}' : 'Scheduled');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            inst.isPaid ? Icons.check_circle : Icons.schedule,
            size: 18,
            color: inst.isPaid ? Colors.green.shade600 : Colors.orange.shade600,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Installment ${inst.seq}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Text(
            _money.format(inst.amount),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(InstallmentPlan plan) {
    final completed = plan.isCompleted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: completed ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        completed ? 'Completed' : 'Active',
        style: TextStyle(
          color: completed ? Colors.green.shade700 : Colors.orange.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            _money.format(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentsData {
  const _PaymentsData({required this.invoices, required this.plans});
  final List<Payment> invoices;
  final List<InstallmentPlan> plans;
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
        const SizedBox(height: 12),
        const Text(
          'Could not load payments',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        Center(
          child: FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ),
      ],
    );
  }
}
