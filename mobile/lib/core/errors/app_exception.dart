/// Custom exception types for structured error handling.
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final List<FieldError>? errors;

  const AppException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => 'AppException($statusCode): $message';
}

class NetworkException extends AppException {
  const NetworkException({super.message = 'Tidak ada koneksi internet'});
}

class TimeoutException extends AppException {
  const TimeoutException({super.message = 'Server tidak merespons'});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Sesi Anda telah berakhir. Silakan login kembali',
    super.statusCode = 401,
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Anda tidak memiliki akses',
    super.statusCode = 403,
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Data tidak ditemukan',
    super.statusCode = 404,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.statusCode = 400,
    super.errors,
  });
}

class ServerException extends AppException {
  const ServerException({
    super.message = 'Terjadi kesalahan server',
    super.statusCode = 500,
  });
}

class ServiceUnavailableException extends AppException {
  const ServiceUnavailableException({
    super.message = 'Fitur realtime sedang tidak tersedia',
    super.statusCode = 503,
  });
}

class FieldError {
  final String field;
  final String message;

  const FieldError({required this.field, required this.message});

  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      field: json['field'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}
