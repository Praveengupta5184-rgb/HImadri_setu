import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'api_client.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  html.EventSource? _eventSource;
  List<Map<String, dynamic>> _notifications = [];
  bool _isConnected = false;

  List<Map<String, dynamic>> get notifications => _notifications;
  List<Map<String, dynamic>> get unreadNotifications => _notifications.where((n) => n['isRead'] == false).toList();
  bool get isConnected => _isConnected;

  void connect(String userId) {
    if (_eventSource != null) return;

    final url = '${ApiClient.baseUrl}/notifications/stream?userId=$userId';
    
    _eventSource = html.EventSource(url);
    
    _eventSource!.onOpen.listen((event) {
      _isConnected = true;
      notifyListeners();
    });

    _eventSource!.addEventListener('notification', (html.Event event) {
      final messageEvent = event as html.MessageEvent;
      final data = json.decode(messageEvent.data);
      _notifications.insert(0, data);
      notifyListeners();
    });

    _eventSource!.onError.listen((event) {
      _isConnected = false;
      notifyListeners();
      // Retry logic could be added here
    });
    
    _fetchExisting(userId);
  }

  Future<void> _fetchExisting(String userId) async {
    final response = await ApiClient.get<List<dynamic>>('/notifications/user/$userId/unread');
    if (response.success && response.data != null) {
      _notifications = List<Map<String, dynamic>>.from(response.data!);
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final response = await ApiClient.put('/notifications/$notificationId/read', {});
    if (response.success) {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
        notifyListeners();
      }
    }
  }

  void disconnect() {
    _eventSource?.close();
    _eventSource = null;
    _isConnected = false;
    notifyListeners();
  }
}
