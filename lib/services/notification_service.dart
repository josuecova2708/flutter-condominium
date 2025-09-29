import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class NotificationService extends ChangeNotifier {
  static const String baseUrl = 'https://backend-condo-production.up.railway.app';
  static const String tokenEndpoint = '/api/notifications/api/fcm-token/';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _isInitialized = false;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    try {
      // Solicitar permisos de notificación
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
        print('✅ Permisos de notificación concedidos');

        // Inicializar notificaciones locales
        await _initializeLocalNotifications();

        // Obtener token FCM
        await _getFCMToken();

        // Configurar listeners
        _setupMessageListeners();

        _isInitialized = true;
        notifyListeners();

        print('🔔 NotificationService inicializado correctamente');
      } else {
        print('❌ Permisos de notificación denegados');
      }
    } catch (e) {
      print('❌ Error inicializando NotificationService: $e');
    }
  }

  /// Inicializar notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Obtener token FCM
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print('📱 FCM Token obtenido: ${_fcmToken?.substring(0, 20)}...');

      // Enviar token al backend
      await _sendTokenToBackend();

      // Escuchar cuando el token se actualice
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _sendTokenToBackend();
      });

    } catch (e) {
      print('❌ Error obteniendo FCM token: $e');
    }
  }

  /// Enviar token al backend
  Future<void> _sendTokenToBackend() async {
    if (_fcmToken == null) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$tokenEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.instance.accessToken}', // Assuming you have this
        },
        body: jsonEncode({
          'fcm_token': _fcmToken,
          'device_type': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Token FCM enviado al backend exitosamente');
      } else {
        print('❌ Error enviando token al backend: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error enviando token al backend: $e');
    }
  }

  /// Configurar listeners de mensajes
  void _setupMessageListeners() {
    // Mensaje recibido cuando la app está en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Mensaje recibido en foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Mensaje tocado cuando la app está en background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 Notificación tocada: ${message.notification?.title}');
      _handleNotificationTap(message);
    });

    // Verificar si la app fue abierta desde una notificación
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('🚀 App abierta desde notificación: ${message.notification?.title}');
        _handleNotificationTap(message);
      }
    });
  }

  /// Mostrar notificación local
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'condominio_channel',
      'Notificaciones Condominio',
      channelDescription: 'Notificaciones del sistema de condominio',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Notificación',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  /// Manejar tap en notificación
  void _handleNotificationTap(RemoteMessage message) {
    final String? type = message.data['type'];
    final String? entityId = message.data['entity_id'];

    switch (type) {
      case 'reservation_confirmed':
        // Navegar a pantalla de reservas
        print('🏠 Navegando a reservas - ID: $entityId');
        break;
      case 'reservation_reminder':
        // Navegar a detalle de reserva
        print('⏰ Recordatorio de reserva - ID: $entityId');
        break;
      case 'new_charge':
        // Navegar a pantalla de pagos
        print('💰 Nuevo cargo - ID: $entityId');
        break;
      default:
        print('🔔 Notificación genérica');
    }
  }

  /// Callback cuando se toca una notificación local
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(payload);
        final RemoteMessage message = RemoteMessage(data: data);
        _handleNotificationTap(message);
      } catch (e) {
        print('❌ Error procesando payload de notificación: $e');
      }
    }
  }

  /// Suscribirse a un tópico
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Suscrito al tópico: $topic');
    } catch (e) {
      print('❌ Error suscribiéndose al tópico $topic: $e');
    }
  }

  /// Desuscribirse de un tópico
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('❌ Desuscrito del tópico: $topic');
    } catch (e) {
      print('❌ Error desuscribiéndose del tópico $topic: $e');
    }
  }

  /// Obtener notificaciones no leídas del backend
  Future<List<Map<String, dynamic>>> getUnreadNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/unread/'),
        headers: {
          'Authorization': 'Bearer ${AuthService.instance.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('❌ Error obteniendo notificaciones no leídas: $e');
    }
    return [];
  }

  /// Marcar notificación como leída
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await http.patch(
        Uri.parse('$baseUrl/api/notifications/$notificationId/read/'),
        headers: {
          'Authorization': 'Bearer ${AuthService.instance.accessToken}',
        },
      );
    } catch (e) {
      print('❌ Error marcando notificación como leída: $e');
    }
  }

  /// Limpiar todos los recursos
  void dispose() {
    // Firebase y notificaciones locales se limpian automáticamente
    super.dispose();
  }
}