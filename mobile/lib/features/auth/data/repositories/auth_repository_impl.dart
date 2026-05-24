import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:eventsync_mobile/core/constants/api_endpoints.dart';
import 'package:eventsync_mobile/core/network/dio_client.dart';
import 'package:eventsync_mobile/features/auth/domain/entities/user.dart';
import 'package:eventsync_mobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'jwt_token';

  AuthRepositoryImpl({required Dio dio, FlutterSecureStorage? storage})
      : _dio = dio,
        _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final result = AuthResult.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
      await _storage.write(key: _tokenKey, value: result.token);
      return result;
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? divisi,
    String? phone,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': 'staf', // Backend only allows staf registration
          if (divisi != null) 'divisi': divisi,
          if (phone != null) 'phone': phone,
        },
      );
      final userData = response.data['data']['user'] as Map<String, dynamic>;
      return User.fromJson(userData);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<User> getMe() async {
    try {
      final response = await _dio.get(ApiEndpoints.me);
      final userData = response.data['data']['user'] as Map<String, dynamic>;
      return User.fromJson(userData);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } on DioException {
      // Best effort — even if server call fails, clear local session
    } finally {
      await clearSession();
    }
  }

  @override
  Future<String?> getStoredToken() async {
    return _storage.read(key: _tokenKey);
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
  }
}
