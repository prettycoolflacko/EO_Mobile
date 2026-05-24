import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:eventsync_mobile/core/constants/app_config.dart';
import 'package:eventsync_mobile/core/errors/app_exception.dart';
import 'package:eventsync_mobile/core/network/auth_interceptor.dart';

/// Singleton Dio client provider.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: AppConfig.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  const storage = FlutterSecureStorage();

  dio.interceptors.addAll([
    AuthInterceptor(
      storage: storage,
      onUnauthorized: () {
        // Trigger auth state change — the router guard will redirect
        ref.read(authStateNotifierProvider.notifier).onUnauthorized();
      },
    ),
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (o) {
        // Only log in debug mode
        assert(() {
          // ignore: avoid_print
          print(o);
          return true;
        }());
      },
    ),
  ]);

  return dio;
});

/// Simple auth state notifier for the interceptor to signal 401.
final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, bool>((ref) {
  return AuthStateNotifier();
});

class AuthStateNotifier extends StateNotifier<bool> {
  AuthStateNotifier() : super(false);

  void onUnauthorized() => state = true;
  void reset() => state = false;
}

/// Converts DioExceptions into typed AppExceptions.
AppException handleDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const TimeoutException();
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.badResponse:
      return _parseErrorResponse(e.response);
    default:
      if (e.error is SocketException) {
        return const NetworkException();
      }
      return AppException(
        message: e.message ?? 'Terjadi kesalahan tidak terduga',
      );
  }
}

AppException _parseErrorResponse(Response? response) {
  if (response == null) {
    return const ServerException();
  }

  final statusCode = response.statusCode ?? 500;
  final data = response.data;

  String message = 'Terjadi kesalahan';
  List<FieldError>? fieldErrors;

  if (data is Map<String, dynamic>) {
    message = data['message'] as String? ?? message;
    if (data['errors'] != null) {
      fieldErrors = (data['errors'] as List)
          .map((e) => FieldError.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  switch (statusCode) {
    case 400:
      return ValidationException(
        message: message,
        errors: fieldErrors,
      );
    case 401:
      return UnauthorizedException(message: message);
    case 403:
      return ForbiddenException(message: message);
    case 404:
      return NotFoundException(message: message);
    case 503:
      return ServiceUnavailableException(message: message);
    default:
      return ServerException(message: message);
  }
}
