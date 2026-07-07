import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/fuel_transaction.dart';
import '../../services/api_client.dart';
import '../../services/nfc_reader.dart';
import '../../services/transaction_service.dart';
import '../../utils/app_colors.dart';

/// Staff-side flow: cashier enters liters + fuel type, taps the customer's
/// card on the phone, and the backend authorizes against the customer's
/// active subscription credit. Result is shown approved (green) or
/// declined (red) with the decline reason.
class TapToPayScreen extends StatefulWidget {
  const TapToPayScreen({super.key});

  @override
  State<TapToPayScreen> createState() => _TapToPayScreenState();
}

class _TapToPayScreenState extends State<TapToPayScreen> {
  final _liters = TextEditingController(text: '20');
  String _fuelType = 'p95';
  bool _busy = false;
  FuelTransaction? _result;
  String? _error;

  final _service = TransactionService();
  final _money = NumberFormat.simpleCurrency(name: 'SAR', decimalDigits: 2);

  @override
  void dispose() {
    _liters.dispose();
    super.dispose();
  }

  Future<void> _runTap() async {
    final liters = double.tryParse(_liters.text.trim());
    if (liters == null || liters <= 0) {
      setState(() => _error = 'Enter a valid liter amount');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
    });
    try {
      final available = await NfcReader.isAvailable();
      if (!available) {
        throw NfcReaderException('NFC is off or unavailable on this device');
      }
      final uid = await NfcReader.readCardId();
      final txn = await _service.authorize(
        cardUid: uid,
        liters: liters,
        fuelType: _fuelType,
      );
      setState(() => _result = txn);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } on NfcReaderException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Liters/fuel inputs sit at the top; keep the layout put when typing.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Tap to pay'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _liters,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Liters',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
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
              ],
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildResultArea()),
            FilledButton(
              onPressed: _busy ? null : _runTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  : const Text('Tap card to authorize',
                      style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultArea() {
    if (_busy) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.nfc, size: 88),
            SizedBox(height: 12),
            Text('Hold customer\'s card on the back of the phone…'),
          ],
        ),
      );
    }

    if (_error != null) {
      return _statusBlock(
        color: Colors.orange.shade700,
        icon: Icons.warning_amber_rounded,
        title: 'Couldn\'t complete tap',
        body: _error!,
      );
    }

    final r = _result;
    if (r == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.contactless_outlined, size: 88, color: Colors.grey.shade500),
            const SizedBox(height: 12),
            const Text('Enter liters, then tap the card'),
          ],
        ),
      );
    }

    if (r.isApproved) {
      return _statusBlock(
        color: Colors.green.shade700,
        icon: Icons.check_circle_outline,
        title: 'Approved',
        body:
            '${r.liters.toStringAsFixed(2)} L · ${_money.format(r.totalAmount)}\n@ ${_money.format(r.pricePerLiter)}/L',
      );
    }
    return _statusBlock(
      color: Colors.red.shade700,
      icon: Icons.block,
      title: 'Declined',
      body: r.declineReason ?? 'Authorization failed',
    );
  }

  Widget _statusBlock({
    required Color color,
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: color),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                )),
            const SizedBox(height: 8),
            Text(body,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
