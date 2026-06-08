import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/exceptions.dart';
import '../models/user_model.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  Future<UserModel> login(String username, String password) async {
    try {
      final res = await ApiClient.instance.post('/login', data: {
        'username': username,
        'password': password,
      });
      final token = res.data['token'] as String;
      final user = UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
      await _storage.write(key: AppConstants.tokenKey, value: token);
      await _storage.write(key: AppConstants.userKey, value: user.toJsonString());
      return user;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post('/logout');
    } catch (_) {}
    await _storage.deleteAll();
    ApiClient.reset();
  }

  Future<UserModel?> getStoredUser() async {
    final raw = await _storage.read(key: AppConstants.userKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async =>
      await _storage.read(key: AppConstants.tokenKey) != null;
}
