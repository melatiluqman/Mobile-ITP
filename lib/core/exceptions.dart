import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiException({required this.message, this.statusCode, this.errors});

  factory ApiException.fromDio(DioException e) {
    final data = e.response?.data;
    String message = 'Terjadi kesalahan';
    if (data is Map) {
      message = data['message'] as String? ?? e.message ?? 'Terjadi kesalahan';
    } else if (e.message != null) {
      message = e.message!;
    }
    return ApiException(
      statusCode: e.response?.statusCode,
      message: message,
      errors: data is Map ? data['errors'] as Map<String, dynamic>? : null,
    );
  }

  bool get isValidation => statusCode == 422;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => (statusCode ?? 0) >= 500;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
