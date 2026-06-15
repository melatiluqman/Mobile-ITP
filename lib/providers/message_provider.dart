import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';
import '../services/message_service.dart';
import '../core/exceptions.dart';

class MessageProvider extends ChangeNotifier {
  List<MessageChannelModel> _channels = [];
  List<MessageModel> _messages = [];
  List<NotificationModel> _notifications = [];
  int _unreadNotifications = 0;
  bool _isLoading = false;
  String? _error;

  List<MessageChannelModel> get channels => _channels;
  List<MessageModel> get messages => _messages;
  List<NotificationModel> get notifications => _notifications;
  int get unreadNotifications => _unreadNotifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  Future<void> loadChannels() async {
    _setLoading(true);
    _error = null;
    try {
      _channels = await MessageService().getChannels();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMessages(int projectId) async {
    _setLoading(true);
    _error = null;
    try {
      final result = await MessageService().getMessages(projectId);
      _messages = result['messages'] as List<MessageModel>;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendMessage(int projectId, String message) async {
    try {
      final msg = await MessageService().sendMessage(projectId, message);
      _messages.add(msg);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadNotifications() async {
    _setLoading(true);
    _error = null;
    try {
      _notifications = await MessageService().getNotifications();
      _unreadNotifications = _notifications.where((n) => !n.isRead).length;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      _unreadNotifications = await MessageService().getUnreadNotificationCount();
      notifyListeners();
    } on ApiException catch (_) {}
  }

  Future<void> markNotificationRead(int id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx == -1 || _notifications[idx].isRead) return;
    try {
      await MessageService().markNotificationRead(id);
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      if (_unreadNotifications > 0) _unreadNotifications--;
      notifyListeners();
    } on ApiException catch (_) {}
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await MessageService().markAllNotificationsRead();
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadNotifications = 0;
      notifyListeners();
    } on ApiException catch (_) {}
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}
