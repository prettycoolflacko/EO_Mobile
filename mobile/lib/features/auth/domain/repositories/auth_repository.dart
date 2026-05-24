import '../entities/user.dart';

/// Auth repository contract.
abstract class AuthRepository {
  Future<AuthResult> login({required String email, required String password});
  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? divisi,
    String? phone,
  });
  Future<User> getMe();
  Future<void> logout();
  Future<String?> getStoredToken();
  Future<void> clearSession();
}

class AuthResult {
  final String token;
  final String tokenType;
  final String expiresIn;
  final User user;

  const AuthResult({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token'] as String,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: json['expires_in'] as String? ?? '24h',
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
