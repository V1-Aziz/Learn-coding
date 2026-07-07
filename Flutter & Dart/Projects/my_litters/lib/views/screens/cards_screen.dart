import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/card.dart';
import '../../services/api_client.dart';
import '../../services/card_service.dart';
import '../../utils/app_colors.dart';
import 'link_card_screen.dart';
import 'phone_card_screen.dart';

/// Lists the user's linked cards (physical + phone) and lets them block or
/// unblock one — e.g. when a card is lost. Backed by /api/cards.
class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final _service = CardService();
  final _dateFmt = DateFormat('MMM d, yyyy');
  late Future<List<FuelCard>> _future;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _future = _service.list();
  }

  void _refresh() => setState(() => _future = _service.list());

  Future<void> _toggleBlock(FuelCard card) async {
    setState(() => _busyId = card.id);
    try {
      if (card.status == 'active') {
        await _service.block(card.id);
      } else {
        await _service.unblock(card.id);
      }
      if (!mounted) return;
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _openAndRefresh(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My cards'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<FuelCard>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final cards = snap.data ?? const <FuelCard>[];
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (snap.hasError)
                  _errorBanner(snap.error.toString())
                else if (cards.isEmpty)
                  _emptyState()
                else
                  ...cards.map(_cardTile),
                const SizedBox(height: 8),
                _addButtons(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _cardTile(FuelCard card) {
    final busy = _busyId == card.id;
    final active = card.status == 'active';
    final uid = card.cardUid;
    final last4 = uid.length >= 4 ? uid.substring(uid.length - 4) : uid;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.credit_card,
                  color: active ? AppColors.primary : Colors.grey, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.label?.isNotEmpty == true ? card.label! : 'Card',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text('•••• $last4',
                        style: TextStyle(
                            color: Colors.grey.shade600, letterSpacing: 1.5)),
                  ],
                ),
              ),
              _statusChip(card.status),
            ],
          ),
          if (card.linkedAt != null) ...[
            const SizedBox(height: 10),
            Text('Linked ${_dateFmt.format(card.linkedAt!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: busy ? null : () => _toggleBlock(card),
              style: OutlinedButton.styleFrom(
                foregroundColor: active ? Colors.red.shade700 : AppColors.success,
                side: BorderSide(
                    color: active ? Colors.red.shade200 : Colors.green.shade200),
              ),
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(active ? Icons.block : Icons.lock_open, size: 18),
              label: Text(active ? 'Block' : 'Unblock'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final map = {
      'active': (Colors.green.shade50, Colors.green.shade700),
      'blocked': (Colors.red.shade50, Colors.red.shade700),
      'lost': (Colors.orange.shade50, Colors.orange.shade700),
    };
    final (bg, fg) = map[status] ?? (Colors.grey.shade100, Colors.grey.shade700);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(status[0].toUpperCase() + status.substring(1),
          style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _addButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openAndRefresh(const LinkCardScreen()),
            icon: const Icon(Icons.add_card),
            label: const Text('Link a physical card'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openAndRefresh(const PhoneCardScreen()),
            icon: const Icon(Icons.smartphone),
            label: const Text('Use this phone as a card'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.info,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.credit_card_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text('No cards linked yet',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Add a physical card or use your phone below.',
              style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _errorBanner(String message) {
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
          Expanded(child: Text(message)),
          TextButton(onPressed: _refresh, child: const Text('Retry')),
        ],
      ),
    );
  }
}
