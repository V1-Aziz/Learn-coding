import 'package:flutter/material.dart';
import '../../controllers/device_card_controller.dart';
import '../../services/api_client.dart';
import '../../services/hce_service.dart';
import '../../utils/app_colors.dart';
import 'link_card_screen.dart';

/// Customer flow: turn the phone itself into the fuel card via Android HCE.
/// On iOS this screen explains the limitation and points to physical cards.
class PhoneCardScreen extends StatefulWidget {
  const PhoneCardScreen({super.key});

  @override
  State<PhoneCardScreen> createState() => _PhoneCardScreenState();
}

class _PhoneCardScreenState extends State<PhoneCardScreen> {
  final _controller = DeviceCardController();
  HceStatus _status = const HceStatus(supported: false, enabled: false);
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _controller.status();
    if (!mounted) return;
    setState(() {
      _status = s;
      _loading = false;
    });
  }

  Future<void> _toggle(bool on) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final s = on ? await _controller.enable() : await _controller.disable();
      if (!mounted) return;
      setState(() => _status = s);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Phone as card'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: !HceService.isPlatformSupported
                  ? _unsupportedView(
                      'Phone-as-card is available on Android only. '
                      'On this device, link a physical card instead.',
                    )
                  : !_status.supported
                      ? _unsupportedView(
                          'Turn on NFC in your system settings to use your '
                          'phone as a card, then come back to this screen.',
                          showLink: false,
                        )
                      : _mainView(),
            ),
    );
  }

  Widget _mainView() {
    final enabled = _status.enabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cardVisual(enabled),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
            title: const Text(
              'Use this phone as a card',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              enabled
                  ? 'Active — hold your phone to the reader to pay.'
                  : 'Off — turn on to pay with a tap of your phone.',
            ),
            value: enabled,
            onChanged: _busy ? null : _toggle,
          ),
        ),
        if (_busy) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(color: Colors.red.shade700),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Your phone shares a secure card ID with the station reader over '
          'NFC. It works alongside any physical cards you\'ve linked.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _cardVisual(bool enabled) {
    final masked = _status.hasCard ? _maskUid(_status.uid!) : '•••• •••• ••••';
    return Container(
      height: 190,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: enabled
              ? [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)]
              : [Colors.grey.shade500, Colors.grey.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Litters',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Icon(enabled ? Icons.contactless : Icons.contactless_outlined,
                  color: Colors.white, size: 30),
            ],
          ),
          const Spacer(),
          Text(masked,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(enabled ? 'READY TO TAP' : 'INACTIVE',
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _unsupportedView(String message, {bool showLink = true}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.phonelink_erase, size: 80, color: Colors.grey.shade500),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
        if (showLink) ...[
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            icon: const Icon(Icons.add_card),
            label: const Text('Link a physical card'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LinkCardScreen()),
            ),
          ),
        ],
      ],
    );
  }

  /// Show only the last 4 hex chars; mask the rest.
  String _maskUid(String uid) {
    if (uid.length <= 4) return uid;
    final last4 = uid.substring(uid.length - 4);
    return '•••• •••• $last4';
  }
}
