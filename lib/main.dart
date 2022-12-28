import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:timezone/data/latest_10y.dart';
import 'package:timezone/timezone.dart' as tz;

//! 4. Create instance of FlutterLocalNotificationPlugin
FlutterLocalNotificationsPlugin localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Logger logger = Logger();

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  //* init timezone
  initializeTimeZones();

  //! 1. Create AndroidNotificationSettings
  AndroidInitializationSettings androidSettings =
      const AndroidInitializationSettings('@drawable/notification');

  //! 2. Create DarwinNotificationSettings (iOS)
  DarwinInitializationSettings iOSSettings = const DarwinInitializationSettings(
    defaultPresentAlert: true,
    defaultPresentBadge: true,
    defaultPresentSound: true,
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestCriticalPermission: true,
    requestSoundPermission: true,
  );

  //! 3. Create InitializationSettings
  InitializationSettings initializationSettings = InitializationSettings(
    android: androidSettings,
    iOS: iOSSettings,
  );

  //! 5. Initialize notification with initialization settings
  bool? initialized = await localNotificationsPlugin.initialize(
    initializationSettings,
    //! provide this to check whether the app is launched by notification from BG
    onDidReceiveNotificationResponse: (NotificationResponse details) {
      String? payload = details.payload;
      logger.v('Payload from bg => $payload');
    },
  );

  logger.v('Notifications: $initialized');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _checkWhetherNotificationLaunchedApp();
  }

  //! call method to check whether the app is launched by notification (initially)
  void _checkWhetherNotificationLaunchedApp() async {
    NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await localNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails != null) {
      if (notificationAppLaunchDetails.didNotificationLaunchApp) {
        NotificationResponse? notificationResponse =
            notificationAppLaunchDetails.notificationResponse;
        if (notificationResponse != null) {
          String? payload = notificationResponse.payload;
          logger.i('Payload from init => $payload');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Container(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // _showSimpleNotification();
            // _showScheduleNotification();
            _showScheduleNotificationWithPayload();
          },
          child: const Icon(Icons.notification_add),
        ),
      ),
    );
  }

  Future<void> _showSimpleNotification() async {
    //! 6. Create android NotificationDetails
    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
      'channel-id',
      'channel-name',
      priority: Priority.max,
      importance: Importance.max,
    );

    //! 7. Create iOS NotificationDetails
    DarwinNotificationDetails iOSDetails = const DarwinNotificationDetails();

    //! 8. create NotificationDetails
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    //! 9. show notification with above notificationDetails
    await localNotificationsPlugin.show(
      3,
      'Title',
      'body',
      notificationDetails,
    );
  }

  Future<void> _showScheduleNotification() async {
    //! create AndroidNotificationDetails
    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
      'cid',
      'cname',
      priority: Priority.max,
      importance: Importance.max,
    );

    //! create iOSNotificationDetails
    DarwinNotificationDetails iOSDetails = const DarwinNotificationDetails(
      presentBadge: true,
    );

    //! create NotificationDetails
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    //! create scheduleDate
    DateTime scheduleDate = DateTime.now().add(const Duration(seconds: 5));

    //! show notification with about details
    await localNotificationsPlugin.zonedSchedule(
      0,
      'title',
      'body',
      tz.TZDateTime.from(scheduleDate, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  Future<void> _showScheduleNotificationWithPayload() async {
    //! create AndroidNotificationDetails
    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
      'cid',
      'cname',
      priority: Priority.max,
      importance: Importance.max,
    );

    //! create iOSNotificationDetails
    DarwinNotificationDetails iOSDetails = const DarwinNotificationDetails(
      presentBadge: true,
    );

    //! create NotificationDetails
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    DateTime scheduleDate = DateTime.now().add(const Duration(seconds: 5));

    await localNotificationsPlugin.zonedSchedule(
      0,
      'title',
      'body',
      tz.TZDateTime.from(scheduleDate, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      androidAllowWhileIdle: true,
      payload: 'I am Payload bro',
    );
  }
}
