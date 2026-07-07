import 'dart:async';
import 'dart:typed_data';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

/// Thin wrapper around the `nfc_manager` plugin.
/// Reads a card's hardware UID and returns it as an upper-case hex string.
class NfcReader {
  /// SELECT (by AID) command for the My Litters HCE applet. The AID
  /// (F0 4D 59 4C 54 52) MUST match res/xml/apduservice.xml.
  static final Uint8List _selectAidApdu = Uint8List.fromList(<int>[
    0x00, 0xA4, 0x04, 0x00, // CLA INS P1 P2 (SELECT by name)
    0x06, // Lc: AID length
    0xF0, 0x4D, 0x59, 0x4C, 0x54, 0x52, // AID "MYLTR"
    0x00, // Le
  ]);

  /// Returns true if the device has NFC and it's currently turned on.
  static Future<bool> isAvailable() async => NfcManager.instance.isAvailable();

  /// Reads a card identifier for authorization. Tries our HCE applet first
  /// (an emulating phone answers the SELECT), then falls back to a physical
  /// card/tag's hardware UID. Use this on the staff/tap-to-pay side so one
  /// tap handles both phones and plastic cards.
  static Future<String> readCardId(
      {Duration timeout = const Duration(seconds: 30)}) async {
    final completer = Completer<String>();
    Timer? timer;

    try {
      timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          completer
              .completeError(NfcReaderException('Timed out waiting for tap'));
        }
      });

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            final viaApdu = await _readViaApdu(tag);
            final id = viaApdu ?? _extractUid(tag);
            if (id == null || id.isEmpty) {
              throw NfcReaderException('Could not read a card ID');
            }
            if (!completer.isCompleted) completer.complete(id);
          } catch (e) {
            if (!completer.isCompleted) {
              completer.completeError(
                e is NfcReaderException ? e : NfcReaderException(e.toString()),
              );
            }
          } finally {
            await NfcManager.instance.stopSession();
          }
        },
      );

      return await completer.future;
    } finally {
      timer?.cancel();
      try {
        await NfcManager.instance.stopSession();
      } catch (_) {}
    }
  }

  /// Selects our AID over IsoDep and parses the returned UID payload.
  /// Returns null when the tag is not our emulating applet, so the caller can
  /// fall back to the hardware UID of a physical card.
  static Future<String?> _readViaApdu(NfcTag tag) async {
    final isoDep = IsoDep.from(tag);
    if (isoDep == null) return null;
    try {
      final resp = await isoDep.transceive(data: _selectAidApdu);
      if (resp.length < 2) return null;
      final sw1 = resp[resp.length - 2];
      final sw2 = resp[resp.length - 1];
      if (sw1 != 0x90 || sw2 != 0x00) return null; // not our applet
      final payload = resp.sublist(0, resp.length - 2);
      if (payload.isEmpty) return null;
      return String.fromCharCodes(payload).trim().toUpperCase();
    } catch (_) {
      return null;
    }
  }

  /// Begins a session, returns the first tag's UID, then stops the session.
  /// Throws [NfcReaderException] on timeout or read failure.
  static Future<String> readUid({Duration timeout = const Duration(seconds: 30)}) async {
    final completer = Completer<String>();
    Timer? timer;

    try {
      timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          completer.completeError(NfcReaderException('Timed out waiting for tap'));
        }
      });

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            final uid = _extractUid(tag);
            if (uid == null) {
              throw NfcReaderException('Tag does not expose a UID');
            }
            if (!completer.isCompleted) completer.complete(uid);
          } catch (e) {
            if (!completer.isCompleted) {
              completer.completeError(
                e is NfcReaderException ? e : NfcReaderException(e.toString()),
              );
            }
          } finally {
            await NfcManager.instance.stopSession();
          }
        },
      );

      return await completer.future;
    } finally {
      timer?.cancel();
      try {
        await NfcManager.instance.stopSession();
      } catch (_) {}
    }
  }

  /// Pulls the hardware UID from whichever tech the tag exposes.
  /// Works for both Android (NfcA / IsoDep) and iOS (Mifare / NDEF).
  static String? _extractUid(NfcTag tag) {
    final data = tag.data;
    // Android shape
    final nfca = (data['nfca'] as Map?)?.cast<String, dynamic>();
    if (nfca != null && nfca['identifier'] is List) {
      return _toHex(List<int>.from(nfca['identifier'] as List));
    }
    // iOS shapes
    for (final key in ['mifare', 'iso7816', 'iso15693', 'felica']) {
      final m = (data[key] as Map?)?.cast<String, dynamic>();
      if (m != null && m['identifier'] is List) {
        return _toHex(List<int>.from(m['identifier'] as List));
      }
    }
    // Fallback: NDEF identifier
    final ndef = (data['ndef'] as Map?)?.cast<String, dynamic>();
    final cachedId = (ndef?['identifier'] as List?);
    if (cachedId != null) {
      return _toHex(List<int>.from(cachedId));
    }
    return null;
  }

  static String _toHex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
}

class NfcReaderException implements Exception {
  NfcReaderException(this.message);
  final String message;
  @override
  String toString() => 'NfcReaderException: $message';
}
