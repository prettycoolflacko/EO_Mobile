import 'package:eventsync_mobile/core/network/api_response.dart';
import 'package:eventsync_mobile/features/auth/domain/entities/user.dart';

abstract class UserRepository {
  Future<ApiResponse<List<User>>> getUsers({
    int page = 1,
    int perPage = 20,
    String? search,
    String? role,
  });

  Future<User> updateUserRole(int id, String newRole);

  Future<User> updateUserDivisi(int id, String divisi);

  Future<void> deleteUser(int id);
}
