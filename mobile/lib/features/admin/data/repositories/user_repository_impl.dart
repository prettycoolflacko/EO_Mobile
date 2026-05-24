import 'package:dio/dio.dart';

import 'package:eventsync_mobile/core/constants/api_endpoints.dart';
import 'package:eventsync_mobile/core/network/api_response.dart';
import 'package:eventsync_mobile/core/network/dio_client.dart';
import 'package:eventsync_mobile/features/auth/domain/entities/user.dart';
import 'package:eventsync_mobile/features/admin/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final Dio _dio;

  UserRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ApiResponse<List<User>>> getUsers({
    int page = 1,
    int perPage = 20,
    String? search,
    String? role,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.users,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (search != null && search.isNotEmpty) 'q': search,
          if (role != null && role.isNotEmpty) 'role': role,
        },
      );

      return ApiResponse<List<User>>.fromJson(
        response.data,
        (json) => (json['users'] as List)
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<User> updateUserRole(int id, String newRole) async {
    try {
      final response = await _dio.patch(
        '${ApiEndpoints.users}/$id/role',
        data: {'role': newRole},
      );
      return User.fromJson(response.data['data']['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<User> updateUserDivisi(int id, String divisi) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.users}/$id',
        data: {'divisi': divisi},
      );
      return User.fromJson(response.data['data']['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    try {
      await _dio.delete('${ApiEndpoints.users}/$id');
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
