import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import '../../services/card_service.dart';
import '../../services/nfc_reader.dart';
import '../../utils/app_colors.dart';

/// Customer-side flow: place a card on the back of the phone, we read
/// its UID, and POST it to /api/cards to link it to the signed-in user.
class LinkCardScreen extends StatefulWidget {
  const LinkCardScreen({super.key});

  @override
  State<LinkCardScreen> createState() => _LinkCardScreenState();
}

class _LinkCardScreenState extends State<LinkCardScreen> {
  final _label = TextEditingController(text: 'Primary card');
  final _service = CardService();
  bool _busy = false;
  String? _uid;
  String? _error;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _readAndLink() async {
    setState(() {
      _busy = true;
      _error = null;
      _uid = null;
    });
    try {
      final available = await NfcReader.isAvailable();
      if (!available) {
        throw NfcReaderException('NFC is off or unavailable on this device');
      }
      final uid = await NfcReader.readUid();
      setState(() => _uid = uid);
      final card = await _service.link(cardUid: uid, label: _label.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Linked card ${card.cardUid.substring(0, 6)}…'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, card);
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
      // Fixed layout with a bottom button — don't let the keyboard shove it up.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Link a card'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _label,
              decoration: const InputDecoration(
                labelText: 'Label (optional)',
                helperText: 'e.g. Sedan, Truck — shown in your card list',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Icon(
                _busy ? Icons.nfc : Icons.contactless_outlined,
                size: 96,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _busy
                    ? 'Hold the card on the back of the phone…'
                    : 'Tap the button, then place your card',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            if (_uid != null) ...[
              const SizedBox(height: 12),
              Center(child: Text('Read UID: $_uid')),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red.shade700),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const Spacer(),
            FilledButton(
              onPressed: _busy ? null : _readAndLink,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text('Scan card to link'),
            ),
          ],
        ),
      ),
    );
  }
}
