import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'item_model.dart' hide Priority;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );
    await _notificationsPlugin.initialize(settings);
  }

  // Existing Schedule Method
  static Future<void> scheduleReminders(List<ShoppingItem> items) async {
    await _notificationsPlugin.cancelAll();
    final now = DateTime.now();
    final unpurchased = items
        .where(
          (i) =>
              !i.isPurchased &&
              i.scheduledDate.year == now.year &&
              i.scheduledDate.month == now.month &&
              i.scheduledDate.day == now.day,
        )
        .toList();

    if (unpurchased.isEmpty) return;

    String itemList = unpurchased.map((i) => i.name).join(", ");

    for (int i = 1; i <= 12; i++) {
      await _notificationsPlugin.zonedSchedule(
        i,
        'Shopping Reminder',
        'Still pending: $itemList',
        tz.TZDateTime.now(tz.local).add(
          Duration(minutes: 30 * i),
        ), // Changed to 30 mins to avoid clash with Market Mode
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'shop_channel_id',
            'Shopping Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  // NEW: Instant Notification for Market Mode
  static Future<void> showMarketNotification(String itemList) async {
    await _notificationsPlugin.show(
      999, // Unique ID for Market Mode
      '🛒 Market Mode Active',
      'Don\'t forget to buy: $itemList',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'market_mode_channel',
          'Market Mode Alerts',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
  }
}
