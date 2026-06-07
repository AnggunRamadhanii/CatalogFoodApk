import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class FirebaseMessagingHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const String channelId = 'high_importance_channel_v3'; 
  static const String channelName = 'Info Promo Penting';

  Future<void> initPushNotification() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) return;

    await _initLocalNotification();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId, 
      channelName, 
      description: 'Channel untuk notifikasi dengan suara kustom',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('mysound'), 
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['route'] != null) {
        Get.toNamed(message.data['route']);
      }
    });
    
    await _checkTerminatedState();
  }

  Future<void> _initLocalNotification() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initSettings = 
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
           Get.toNamed(response.payload!);
        }
      },
    );
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId, 
      channelName,
      channelDescription: 'Notifikasi Suara Kustom',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('mysound'), 
    );

    NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,                 
      message.notification?.title,     
      message.notification?.body,       
      platformDetails,
      payload: message.data['route'],   
    );
  }

  Future<void> _checkTerminatedState() async {
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null && initialMessage.data['route'] != null) {
      Future.delayed(const Duration(seconds: 1), () {
        Get.toNamed(initialMessage.data['route']);
      });
    }
  }
}