import 'package:flutter/material.dart';
import '../../controllers/vehicles_controller.dart';
import '../../models/vehicle.dart';
import '../../services/api_client.dart';
import '../../utils/app_colors.dart';
import '../widgets/vehicle_card.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final _controller = VehiclesController();
  late Future<List<Vehicle>> _future;

  @override
  void initState() {
    super.initState();
    _future = _controller.getVehicles();
  }

  void _refresh() {
    setState(() => _future = _controller.getVehicles());
  }

  Future<void> _openAddSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddVehicleSheet(),
    );
    if (result == true) _refresh();
  }

  Future<void> _confirmRemove(Vehicle v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove vehicle?'),
        content: Text(
          'Remove ${v.plateNumber} (${v.fuelTypeLabel}) from your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _controller.removeVehicle(v.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle removed')),
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
    final screenSize = MediaQuery.of(context).size;
    final isMediumScreen = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: (ModalRoute.of(context)?.canPop ?? false)
            ? IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.black87, size: 26),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Vehicle Information',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add vehicle'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<Vehicle>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return _ErrorState(
                message: snap.error.toString(),
                onRetry: _refresh,
              );
            }
            final vehicles = snap.data ?? const <Vehicle>[];
            if (vehicles.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(40),
                children: const [
                  SizedBox(height: 60),
                  Icon(Icons.directions_car_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No vehicles yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tap "Add vehicle" to register your first car.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              );
            }
            return SingleChildScrollView(
              padding: EdgeInsets.all(isMediumScreen ? 30.0 : 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: vehicles
                    .map((v) => Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: VehicleCard(
                            vehicle: v,
                            onRemove: () => _confirmRemove(v),
                          ),
                        ))
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
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
        Text(
          'Could not load vehicles',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(message, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        Center(
          child: FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ),
      ],
    );
  }
}

class _AddVehicleSheet extends StatefulWidget {
  const _AddVehicleSheet();

  @override
  State<_AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends State<_AddVehicleSheet> {
  final _form = GlobalKey<FormState>();
  final _plate = TextEditingController();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  String _fuelType = 'p95';
  bool _busy = false;
  String? _error;

  final _controller = VehiclesController();

  @override
  void dispose() {
    _plate.dispose();
    _make.dispose();
    _model.dispose();
    _year.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _controller.addVehicle(
        plateNumber: _plate.text.trim(),
        make: _make.text.trim(),
        model: _model.text.trim(),
        year: int.tryParse(_year.text.trim()),
        fuelType: _fuelType,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Add a vehicle',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _plate,
              decoration: const InputDecoration(
                labelText: 'Plate number',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _make,
                  decoration: const InputDecoration(
                    labelText: 'Make',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _model,
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _year,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _fuelType,
                  decoration: const InputDecoration(
                    labelText: 'Fuel',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'p91', child: Text('Petrol 91')),
                    DropdownMenuItem(value: 'p95', child: Text('Petrol 95')),
                    DropdownMenuItem(value: 'diesel', child: Text('Diesel')),
                  ],
                  onChanged: (v) => setState(() => _fuelType = v ?? 'p95'),
                ),
              ),
            ]),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text('Save vehicle'),
            ),
          ],
        ),
      ),
    );
  }
}
