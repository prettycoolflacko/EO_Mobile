import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Intercepts requests to inject JWT token and handles 401 auto-logout.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final void Function()? onUnauthorized;

  AuthInterceptor({
    required FlutterSecureStorage storage,
    this.onUnauthorized,
  }) : _storage = storage;

  static const String _tokenKey = 'jwt_token';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] ??= 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Clear stored token and trigger logout redirect
      _storage.delete(key: _tokenKey);
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
