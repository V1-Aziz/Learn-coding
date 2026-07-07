import '../services/api_client.dart';
import '../services/card_service.dart';
import '../services/hce_service.dart';

/// Coordinates the "use this phone as a card" flow: it provisions a virtual
/// card UID, links it to the signed-in user on the backend, and toggles the
/// native HCE emulation on or off.
class DeviceCardController {
  DeviceCardController([CardService? cards]) : _cards = cards ?? CardService();
  final CardService _cards;

  Future<HceStatus> status() => HceService.status();

  Future<bool> isSupported() => HceService.isSupported();

  /// Enables emulation. On first use this generates a UID and registers it as
  /// a card so staff taps can authorize against it. A pre-existing UID (from a
  /// previous enable) is reused, so re-enabling never creates duplicates.
  Future<HceStatus> enable({String label = 'This phone'}) async {
    final current = await HceService.status();
    var uid = current.uid;

    if (uid == null || uid.isEmpty) {
      uid = HceService.generateUid();
      try {
        await _cards.link(cardUid: uid, label: label);
      } on ApiException catch (e) {
        // 409 means the UID is already registered (e.g. a retry) — fine to
        // proceed and emulate it. Anything else is a real failure.
        if (e.statusCode != 409) rethrow;
      }
    }

    await HceService.enable(uid);
    return HceService.status();
  }

  Future<HceStatus> disable() async {
    await HceService.disable();
    return HceService.status();
  }
}
