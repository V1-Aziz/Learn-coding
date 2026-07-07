import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/dashboard_controller.dart';
import '../../services/dashboard_service.dart';
import '../../state/session.dart';
import '../../utils/app_colors.dart';
import '../widgets/fuel_meter_card.dart';
import '../widgets/number_card.dart';
import 'link_card_screen.dart';
import 'login_screen.dart';
import 'payments_screen.dart';
import 'phone_card_screen.dart';
import 'settings_screen.dart';
import 'subscriptions_screen.dart';
import 'tap_to_pay_screen.dart';
import 'vehicles_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const VehiclesNavPage(),
    const PaymentsNavPage(),
    const SettingsNavPage(),
  ];

  void _onNavigationItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavigationItemSelected,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Vehicles',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Payments'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = DashboardController();
  late Future<DashboardSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = _controller.getSummary();
  }

  void _refresh() => setState(() => _future = _controller.getSummary());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<Session>().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<DashboardSummary>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final summary = snap.hasError
                ? DashboardSummary.empty()
                : (snap.data ?? DashboardSummary.empty());
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _CardActionsRow(
                      isStaff:
                          context.watch<Session>().user?.role != 'customer',
                    ),
                    const SizedBox(height: 16),
                    if (snap.hasError)
                      _DashboardErrorBanner(
                        message: snap.error.toString(),
                        onRetry: _refresh,
                      ),
                    if (summary.fuelMeters.isEmpty && !snap.hasError)
                      _NoPlanBanner(onChanged: _refresh),
                    ...summary.fuelMeters.map((meter) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: FuelMeterCard(
                            label: meter.label,
                            remaining: meter.remaining,
                            total: meter.total,
                            color: meter.label.contains('95')
                                ? AppColors.fuel95
                                : AppColors.fuel91,
                          ),
                        )),
                    NumberCard(
                      title: 'Next Payment',
                      value: summary.nextPaymentDays,
                      subtitle: summary.nextPaymentAmount,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 12),
                    NumberCard(
                      title: 'Active Vehicles',
                      value: '${summary.activeVehicles}',
                      subtitle: 'Cars registered',
                      color: AppColors.info,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NoPlanBanner extends StatelessWidget {
  const _NoPlanBanner({required this.onChanged});

  /// Called after returning from the Subscriptions screen so the dashboard
  /// re-fetches and the banner clears once a plan becomes active.
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber.shade800),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'No active subscription. Pick a plan to start using your card.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.list_alt, size: 18),
              label: const Text('Subscriptions'),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SubscriptionsScreen(),
                  ),
                );
                onChanged();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardErrorBanner extends StatelessWidget {
  const _DashboardErrorBanner({
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class VehiclesNavPage extends StatelessWidget {
  const VehiclesNavPage({super.key});

  @override
  Widget build(BuildContext context) => const VehiclesScreen();
}

class PaymentsNavPage extends StatelessWidget {
  const PaymentsNavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Payments', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: const PaymentsScreen(),
    );
  }
}

class SettingsNavPage extends StatelessWidget {
  const SettingsNavPage({super.key});

  @override
  Widget build(BuildContext context) => const SettingsScreen();
}

/// Quick-access tiles for NFC actions.
/// Customers see "Link a card"; staff/admin also see "Tap to pay".
class _CardActionsRow extends StatelessWidget {
  const _CardActionsRow({required this.isStaff});
  final bool isStaff;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.add_card,
            label: 'Link a card',
            color: AppColors.primary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LinkCardScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            icon: Icons.smartphone,
            label: 'Phone card',
            color: AppColors.info,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PhoneCardScreen()),
            ),
          ),
        ),
        if (isStaff) const SizedBox(width: 12),
        if (isStaff)
          Expanded(
            child: _ActionTile(
              icon: Icons.contactless,
              label: 'Tap to pay',
              color: AppColors.success,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TapToPayScreen()),
              ),
            ),
          ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
