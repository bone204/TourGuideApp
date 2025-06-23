import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tourguideapp/models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;

  // Khởi tạo service
  Future<void> initialize() async {
    try {
      // Cấu hình local notifications
      await _initializeLocalNotifications();
      
      // Cấu hình FCM
      await _initializeFCM();
      
      // Lắng nghe thông báo khi app đang chạy
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Lắng nghe khi user tap vào thông báo
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings();
      
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      print('Local notifications initialized successfully');
    } catch (e) {
      print('Error initializing local notifications: $e');
    }
  }

  Future<void> _initializeFCM() async {
    // Yêu cầu quyền thông báo
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Lấy FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $_fcmToken');
  }

  // Đăng ký FCM token cho user
  Future<void> registerUserToken(String userId) async {
    
    if (_fcmToken != null) {
      try {
        await _firestore.collection('USER_FCM_TOKENS').doc(userId).set({
          'fcmToken': _fcmToken,
          'userId': userId,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        print('FCM token registered for user: $userId');
      } catch (e) {
        print('Error registering FCM token: $e');
      }
    }
  }

  // Gửi thông báo cho user cụ thể
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required String serviceType,
    required String serviceId,
    required String serviceName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Kiểm tra xem notification đã tồn tại chưa để tránh duplicate
      final existingNotification = await _firestore
          .collection('NOTIFICATIONS')
          .where('userId', isEqualTo: userId)
          .where('serviceType', isEqualTo: serviceType)
          .where('serviceId', isEqualTo: serviceId)
          .where('title', isEqualTo: title)
          .limit(1)
          .get();

      if (existingNotification.docs.isNotEmpty) {
        print('Notification already exists, skipping duplicate: $serviceId');
        return;
      }

      // Lưu thông báo vào Firestore
      final notification = NotificationModel(
        id: '',
        userId: userId,
        title: title,
        body: body,
        serviceType: serviceType,
        serviceId: serviceId,
        serviceName: serviceName,
        createdAt: DateTime.now(),
        additionalData: additionalData,
      );

      await _firestore.collection('NOTIFICATIONS').add(notification.toMap());
      print('Notification saved to Firestore successfully');

      // Hiển thị local notification (có thể fail nhưng không ảnh hưởng đến việc lưu)
      try {
        await _showLocalNotification(title, body, serviceType, serviceId);
      } catch (e) {
        print('Local notification failed but notification was saved: $e');
      }

      print('Notification sent to user: $userId');
    } catch (e) {
      print('Error sending notification: $e');
      throw Exception('Không thể gửi thông báo: $e');
    }
  }

  // Hiển thị local notification
  Future<void> _showLocalNotification(
    String title,
    String body,
    String serviceType,
    String serviceId,
  ) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'used_services_channel',
        'Used Services Notifications',
        channelDescription: 'Notifications for used services',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        platformChannelSpecifics,
        payload: json.encode({
          'serviceType': serviceType,
          'serviceId': serviceId,
        }),
      );
      
      print('Local notification shown successfully');
    } catch (e) {
      print('Error showing local notification: $e');
      // Fallback: chỉ lưu vào Firestore mà không hiển thị local notification
    }
  }

  // Xử lý thông báo khi app đang chạy
  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      
      // Hiển thị local notification
      _showLocalNotification(
        message.notification!.title ?? 'Thông báo mới',
        message.notification!.body ?? '',
        message.data['serviceType'] ?? '',
        message.data['serviceId'] ?? '',
      );
    }
  }

  // Xử lý khi user tap vào thông báo
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.data}');
    // Có thể navigate đến màn hình chi tiết service ở đây
  }

  // Xử lý khi user tap vào local notification
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final data = json.decode(response.payload!);
      print('Local notification tapped: $data');
      // Có thể navigate đến màn hình chi tiết service ở đây
    }
  }

  // Lấy danh sách thông báo của user
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      print('Debug: Fetching notifications for user: $userId');
      final snapshot = await _firestore
          .collection('NOTIFICATIONS')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      print('Debug: Raw Firestore data:');
      for (var doc in snapshot.docs) {
        print('Debug: Doc ID: ${doc.id}, Data: ${doc.data()}');
      }

      final notifications = snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .toList();
      
      print('Debug: Found ${notifications.length} notifications for user: $userId');
      return notifications;
    } catch (e) {
      print('Error fetching notifications: $e');
      // Fallback: thử query đơn giản hơn
      try {
        print('Debug: Trying simple query without orderBy');
        final snapshot = await _firestore
            .collection('NOTIFICATIONS')
            .where('userId', isEqualTo: userId)
            .get();

        print('Debug: Raw Firestore data (simple query):');
        for (var doc in snapshot.docs) {
          print('Debug: Doc ID: ${doc.id}, Data: ${doc.data()}');
        }

        final notifications = snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList();
        
        // Sort manually
        notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        print('Debug: Found ${notifications.length} notifications with simple query');
        return notifications;
      } catch (e2) {
        print('Error with simple query: $e2');
        return [];
      }
    }
  }

  // Đánh dấu thông báo đã đọc
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('NOTIFICATIONS')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Đánh dấu tất cả thông báo đã đọc
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('NOTIFICATIONS')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Đếm số thông báo chưa đọc
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      print('Debug: Counting unread notifications for user: $userId');
      final snapshot = await _firestore
          .collection('NOTIFICATIONS')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final count = snapshot.docs.length;
      print('Debug: Found $count unread notifications for user: $userId');
      return count;
    } catch (e) {
      print('Error getting unread notification count: $e');
      return 0;
    }
  }

  // Xóa thông báo
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('NOTIFICATIONS').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  // Xóa tất cả thông báo của user
  Future<void> deleteAllUserNotifications(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('NOTIFICATIONS')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error deleting all user notifications: $e');
    }
  }

  // Test notification để kiểm tra
  Future<void> testNotification() async {
    try {
      await sendNotificationToUser(
        userId: 'test_user',
        title: 'Test Notification',
        body: 'This is a test notification to check if the system works!',
        serviceType: 'test',
        serviceId: 'test_001',
        serviceName: 'Test Service',
        additionalData: {'test': true},
      );
      print('Test notification sent successfully');
    } catch (e) {
      print('Test notification failed: $e');
    }
  }

  // Xóa notification duplicate
  Future<void> removeDuplicateNotifications(String userId) async {
    try {
      print('Removing duplicate notifications for user: $userId');
      
      // Lấy tất cả notifications của user
      final snapshot = await _firestore
          .collection('NOTIFICATIONS')
          .where('userId', isEqualTo: userId)
          .get();

      final notifications = snapshot.docs;
      final seen = <String>{};
      final toDelete = <String>[];

      for (var doc in notifications) {
        final data = doc.data();
        final key = '${data['serviceType']}_${data['serviceId']}_${data['title']}';
        
        if (seen.contains(key)) {
          toDelete.add(doc.id);
        } else {
          seen.add(key);
        }
      }

      if (toDelete.isNotEmpty) {
        final batch = _firestore.batch();
        for (var docId in toDelete) {
          batch.delete(_firestore.collection('NOTIFICATIONS').doc(docId));
        }
        await batch.commit();
        print('Removed ${toDelete.length} duplicate notifications');
      } else {
        print('No duplicate notifications found');
      }
    } catch (e) {
      print('Error removing duplicate notifications: $e');
    }
  }
} 