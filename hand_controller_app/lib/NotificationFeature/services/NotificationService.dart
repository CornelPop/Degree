import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {

    tz.initializeTimeZones(); // Initialize timezone data

    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInitSettings);
    await notificationsPlugin.initialize(initSettings, onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {});
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'appointment_channel',
        'Appointment Reminders',
        channelDescription: 'Notifies users about upcoming appointments',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  Future<void> showNotification({int id = 0, String? title, String? body}) async {
    return notificationsPlugin.show(id, title, body, notificationDetails());
  }

  Future<void> scheduleAppointmentNotification({int id = 0, String? title, String? body, required DateTime scheduledNotificationDateTime}) async {

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      scheduledNotificationDateTime,
      tz.local,
    );

    print("Scheduling notification for: $scheduledDate");

    return notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

}
