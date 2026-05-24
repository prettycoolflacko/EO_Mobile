import 'package:eventsync_mobile/core/errors/app_exception.dart';

/// Generic API response wrapper matching the backend format:
/// { "success": bool, "message": str, "data": T?, "meta": PaginationMeta? }
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final PaginationMeta? meta;
  final List<FieldError>? errors;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      meta: json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      errors: json['errors'] != null
          ? (json['errors'] as List)
              .map((e) => FieldError.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class PaginationMeta {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
    );
  }

  bool get hasNextPage => page < totalPages;
}
