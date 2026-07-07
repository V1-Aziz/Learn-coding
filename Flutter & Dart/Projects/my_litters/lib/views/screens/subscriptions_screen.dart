import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controllers/subscriptions_controller.dart';
import '../../models/subscription_plan.dart';
import '../../utils/app_colors.dart';
import 'checkout_screen.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final _controller = SubscriptionsController();
  final _num = NumberFormat('#,##0.00');

  late Future<_PlansBundle> _future;

  /// Tier name whose card is currently expanded to reveal grade selection.
  String? _expandedTier;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_PlansBundle> _load() async {
    final plans = await _controller.getPlans();
    ActiveSubscription? active;
    try {
      active = await _controller.getActive();
    } catch (_) {
      active = null;
    }
    return _PlansBundle(plans: plans, active: active);
  }

  void _refresh() => setState(() => _future = _load());

  /// Group the flat plan list into tiers (Basic, Plus), each carrying its
  /// three fuel-grade variants sorted 91 → 95 → Diesel.
  List<_Tier> _groupTiers(List<SubscriptionPlan> plans) {
    const order = {'p91': 0, 'p95': 1, 'diesel': 2};
    final byName = <String, List<SubscriptionPlan>>{};
    for (final p in plans) {
      byName.putIfAbsent(p.name, () => []).add(p);
    }
    final tiers = byName.entries.map((e) {
      final grades = [...e.value]
        ..sort((a, b) =>
            (order[a.fuelType] ?? 99).compareTo(order[b.fuelType] ?? 99));
      final first = grades.first;
      return _Tier(
        name: e.key,
        liters: first.monthlyLitersLimit,
        recommendation: first.recommendation,
        grades: grades,
      );
    }).toList()
      ..sort((a, b) => a.liters.compareTo(b.liters));
    return tiers;
  }

  Color _gradeColor(String fuelType) {
    switch (fuelType) {
      case 'p91':
        return AppColors.fuelGreen;
      case 'diesel':
        return AppColors.fuelAmber;
      case 'p95':
      default:
        return AppColors.fuelRed;
    }
  }

  /// Pay-first flow: choosing a grade opens the checkout page. The plan only
  /// becomes active after the user pays there. We refresh on return so the
  /// "Current" markers update.
  Future<void> _select(SubscriptionPlan plan) async {
    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CheckoutScreen(plan: plan)),
    );
    if (!mounted) return;
    if (paid == true) {
      setState(() => _expandedTier = null);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.subscriptionBackground,
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<_PlansBundle>(
          future: _future,
          builder: (context, snap) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildCustomAppBar(),
                  if (snap.connectionState != ConnectionState.done)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (snap.hasError)
                    _ErrorBox(message: snap.error.toString(), onRetry: _refresh)
                  else
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: _groupTiers(snap.data!.plans)
                            .map((tier) => Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: _buildTierCard(
                                    tier,
                                    snap.data!.active,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          const Text(
            'Subscription Plans',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _buildTierCard(_Tier tier, ActiveSubscription? active) {
    final activePlanId = active?.plan.id;
    final currentInTier = tier.grades.any((g) => g.id == activePlanId);
    final expanded = _expandedTier == tier.name;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: currentInTier
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: currentInTier
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tier.name,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (currentInTier) ...[
                          const SizedBox(width: 8),
                          _currentPill(),
                        ],
                      ],
                    ),
                    Text(
                      '${tier.liters} L / month',
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => setState(
                    () => _expandedTier = expanded ? null : tier.name),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      expanded ? Colors.grey.shade300 : AppColors.primary,
                  foregroundColor: expanded ? Colors.black87 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  expanded
                      ? 'Close'
                      : (currentInTier ? 'Change' : 'Select'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tier.recommendation,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildGradeColumns(tier, activePlanId, expanded),
          ),
        ],
      ),
    );
  }

  /// One column per grade: the colored price box, plus a Select button
  /// underneath it when the tier card is expanded.
  List<Widget> _buildGradeColumns(
    _Tier tier,
    String? activePlanId,
    bool expanded,
  ) {
    final cols = <Widget>[];
    for (var i = 0; i < tier.grades.length; i++) {
      final plan = tier.grades[i];
      final isCurrent = plan.id == activePlanId;
      if (i > 0) cols.add(const SizedBox(width: 8));
      cols.add(
        Expanded(
          child: Column(
            children: [
              _gradeBox(plan: plan, isCurrent: isCurrent),
              if (expanded) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrent ? null : () => _select(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gradeColor(plan.fuelType),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primary,
                      disabledForegroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isCurrent ? 'Current' : 'Select',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return cols;
  }

  Widget _gradeBox({
    required SubscriptionPlan plan,
    required bool isCurrent,
  }) {
    final color = _gradeColor(plan.fuelType);
    final monthly = plan.pricePerLiter * plan.monthlyLitersLimit;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border:
            isCurrent ? Border.all(color: Colors.white, width: 2) : null,
        boxShadow: isCurrent
            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)]
            : null,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              plan.gradeShort,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${_num.format(monthly)} SAR',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text(
            '/ Month',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Current',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Tier {
  const _Tier({
    required this.name,
    required this.liters,
    required this.recommendation,
    required this.grades,
  });
  final String name;
  final int liters;
  final String recommendation;
  final List<SubscriptionPlan> grades;
}

class _PlansBundle {
  const _PlansBundle({required this.plans, required this.active});
  final List<SubscriptionPlan> plans;
  final ActiveSubscription? active;
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text('Could not load plans',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
