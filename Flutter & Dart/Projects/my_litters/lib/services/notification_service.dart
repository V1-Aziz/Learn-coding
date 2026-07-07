import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/installment.dart';

/// Schedules local reminders for upcoming BNPL installments. Best-effort:
/// every method is safe to call on any platform and swallows failures so a
/// missing permission never breaks the app flow.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static const _channelId = 'installment_reminders';
  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'Payment reminders',
      channelDescription: 'Reminders for upcoming BNPL installments',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// One-time init: timezone database + local zone + plugin channels.
  static Future<void> init() async {
    if (_ready) return;
    try {
      tzdata.initializeTimeZones();
      final localName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (_) {
      // Fall back to UTC if the device zone can't be resolved.
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _ready = true;
  }

  /// Prompts for the notification permission (Android 13+ / iOS).
  static Future<void> requestPermission() async {
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {/* ignore */}
  }

  /// Rebuilds all scheduled reminders from the current plan state: one
  /// notification at 10:00 the day before each unpaid, future installment.
  static Future<void> syncInstallmentReminders(
      List<InstallmentPlan> plans) async {
    try {
      if (!_ready) await init();
      await _plugin.cancelAll();

      final now = tz.TZDateTime.now(tz.local);
      var id = 1000;
      for (final plan in plans) {
        for (final inst in plan.installments) {
          final due = inst.dueDate;
          if (inst.isPaid || due == null) continue;

          final remindAt = tz.TZDateTime(tz.local, due.year, due.month, due.day, 10)
              .subtract(const Duration(days: 1));
          if (!remindAt.isAfter(now)) continue; // skip past reminders

          await _plugin.zonedSchedule(
            id++,
            'Payment due tomorrow',
            'Installment ${inst.seq} of ${plan.months} — '
                '${inst.amount.toStringAsFixed(2)} SAR',
            remindAt,
            _details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }
    } catch (_) {/* best-effort; never block the UI */}
  }

  static Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {/* ignore */}
  }
}
