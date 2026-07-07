import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/services.dart';

/// Snapshot of the device's card-emulation state, mirrored from the native
/// SharedPreferences via the `my_litters/hce` MethodChannel.
class HceStatus {
  const HceStatus({
    required this.supported,
    required this.enabled,
    this.uid,
  });

  /// Device has HCE hardware AND NFC is currently switched on.
  final bool supported;

  /// The phone is currently advertising itself as the card.
  final bool enabled;

  /// The hex UID being emulated (also the UID linked on the backend).
  final String? uid;

  bool get hasCard => uid != null && uid!.isNotEmpty;
}

/// Bridges to the Android Host Card Emulation service. iOS has no equivalent
/// (Apple reserves card emulation for Apple Pay), so every call degrades to a
/// safe "unsupported" result off-Android.
class HceService {
  static const MethodChannel _channel = MethodChannel('my_litters/hce');

  /// Card emulation only exists on Android in this app.
  static bool get isPlatformSupported => Platform.isAndroid;

  static Future<bool> isSupported() async {
    if (!isPlatformSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<HceStatus> status() async {
    if (!isPlatformSupported) {
      return const HceStatus(supported: false, enabled: false);
    }
    try {
      final m = await _channel.invokeMapMethod<String, dynamic>('status');
      return HceStatus(
        supported: m?['supported'] == true,
        enabled: m?['enabled'] == true,
        uid: m?['uid'] as String?,
      );
    } on PlatformException {
      return const HceStatus(supported: false, enabled: false);
    } on MissingPluginException {
      return const HceStatus(supported: false, enabled: false);
    }
  }

  /// Starts emulating [uid]. The native side persists it so the card keeps
  /// working even when the app is backgrounded.
  static Future<void> enable(String uid) async {
    if (!isPlatformSupported) return;
    await _channel.invokeMethod('enable', {'uid': uid});
  }

  /// Stops emulation. The stored UID is kept so it can be re-enabled without
  /// registering a new card.
  static Future<void> disable() async {
    if (!isPlatformSupported) return;
    await _channel.invokeMethod('disable');
  }

  /// A random 14-hex-char UID — shaped like a 7-byte card serial and made of
  /// hex only, so the backend's `normalizeUid` keeps it intact.
  static String generateUid() {
    final rnd = Random.secure();
    final sb = StringBuffer();
    for (var i = 0; i < 14; i++) {
      sb.write(rnd.nextInt(16).toRadixString(16));
    }
    return sb.toString().toUpperCase();
  }
}
