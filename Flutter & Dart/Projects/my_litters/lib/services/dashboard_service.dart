import 'package:intl/intl.dart';
import '../models/installment.dart';
import '../models/payment.dart';
import '../models/subscription_plan.dart';
import '../models/vehicle.dart';
import 'installment_service.dart';
import 'payment_service.dart';
import 'subscription_service.dart';
import 'vehicle_service.dart';

class FuelMeter {
  final String label;
  final int remaining;
  final int total;

  const FuelMeter({
    required this.label,
    required this.remaining,
    required this.total,
  });
}

class DashboardSummary {
  final List<FuelMeter> fuelMeters;
  final String nextPaymentDays;
  final String nextPaymentAmount;
  final int activeVehicles;

  const DashboardSummary({
    required this.fuelMeters,
    required this.nextPaymentDays,
    required this.nextPaymentAmount,
    required this.activeVehicles,
  });

  factory DashboardSummary.empty() => const DashboardSummary(
        fuelMeters: [],
        nextPaymentDays: 'No plan',
        nextPaymentAmount: 'Choose a plan to start',
        activeVehicles: 0,
      );
}

/// Composes the home-screen view by hitting several endpoints in parallel.
class DashboardService {
  DashboardService({
    SubscriptionService? subs,
    VehicleService? vehicles,
    PaymentService? payments,
    InstallmentService? installments,
  })  : _subs = subs ?? SubscriptionService(),
        _vehicles = vehicles ?? VehicleService(),
        _payments = payments ?? PaymentService(),
        _installments = installments ?? InstallmentService();

  final SubscriptionService _subs;
  final VehicleService _vehicles;
  final PaymentService _payments;
  final InstallmentService _installments;

  static final _money =
      NumberFormat.simpleCurrency(name: 'SAR', decimalDigits: 2);

  Future<DashboardSummary> getSummary() async {
    // Run independent calls in parallel; tolerate per-call failures.
    final results = await Future.wait<dynamic>([
      _subs.getCredit().catchError((_) => null),
      _vehicles.list().catchError((_) => <Vehicle>[]),
      _payments.listInvoices().catchError((_) => <Payment>[]),
      _installments.listPlans().catchError((_) => <InstallmentPlan>[]),
    ]);

    final credit = results[0] as CreditSnapshot?;
    final vehicles = (results[1] as List).cast<Vehicle>();
    final invoices = (results[2] as List).cast<Payment>();
    final plans = (results[3] as List).cast<InstallmentPlan>();

    final meters = <FuelMeter>[];
    if (credit != null) {
      // BNPL credit, treated as "liters of headroom" using plan's price.
      final plan = credit.plan;
      final litersHeadroom = plan.pricePerLiter > 0
          ? (credit.availableCredit / plan.pricePerLiter).floor()
          : 0;
      meters.add(FuelMeter(
        label: '${plan.fuelTypeLabel} cap',
        remaining: litersHeadroom.clamp(0, plan.monthlyLitersLimit).toInt(),
        total: plan.monthlyLitersLimit,
      ));
    }

    // Next payment due: soonest among pending installments and unpaid
    // invoices. Installments are the BNPL schedule; invoices are fuel bills.
    String nextDays = '—';
    String nextAmount = 'No upcoming payment';
    DateTime? bestDue;
    double bestAmount = 0;
    for (final plan in plans) {
      for (final inst in plan.installments) {
        if (inst.isPaid || inst.dueDate == null) continue;
        if (bestDue == null || inst.dueDate!.isBefore(bestDue)) {
          bestDue = inst.dueDate;
          bestAmount = inst.amount;
        }
      }
    }
    for (final p in invoices.where((p) => !p.isPaid)) {
      if (p.dueDate == null) continue;
      if (bestDue == null || p.dueDate!.isBefore(bestDue)) {
        bestDue = p.dueDate;
        bestAmount = p.amount;
      }
    }
    if (bestDue != null) {
      nextDays = _dueLabel(bestDue);
      nextAmount = '${_money.format(bestAmount)} due';
    }

    return DashboardSummary(
      fuelMeters: meters,
      nextPaymentDays: nextDays,
      nextPaymentAmount: nextAmount,
      activeVehicles: vehicles.length,
    );
  }

  /// Human-friendly relative due label, e.g. "Due today", "Due in 30 days".
  static String _dueLabel(DateTime due) {
    final now = DateTime.now();
    final days = DateTime(due.year, due.month, due.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (days == 0) return 'Due today';
    if (days > 0) return 'Due in $days day${days == 1 ? '' : 's'}';
    return 'Overdue ${-days}d';
  }
}
