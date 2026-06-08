import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/exceptions.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';

class MessageService {
  Future<List<MessageChannelModel>> getChannels() async {
    try {
      final res = await ApiClient.instance.get('/messages/channels');
      return (res.data as List)
          .map((c) => MessageChannelModel.fromJson(c as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> getMessages(int projectId) async {
    try {
      final res = await ApiClient.instance.get('/messages/$projectId');
      final data = res.data as Map<String, dynamic>;
      return {
        'messages': (data['messages'] as List)
            .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
            .toList(),
        'members': (data['members'] as List)
            .map((m) => MemberModel.fromJson(m as Map<String, dynamic>))
            .toList(),
      };
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<MessageModel> sendMessage(int projectId, String message) async {
    try {
      final res = await ApiClient.instance.post('/messages/send', data: {
        'project_id': projectId,
        'message': message,
      });
      return MessageModel.fromJson(res.data['message'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final res = await ApiClient.instance.get('/notifications');
      return (res.data as List)
          .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      final res = await ApiClient.instance.get('/notifications/unread-count');
      return res.data['count'] as int? ?? 0;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> markNotificationRead(int id) async {
    try {
      await ApiClient.instance.post('/notifications/$id/mark-read');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await ApiClient.instance.post('/notifications/mark-all-read');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
