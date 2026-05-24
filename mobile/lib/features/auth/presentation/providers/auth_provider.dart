import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eventsync_mobile/core/errors/app_exception.dart';
import 'package:eventsync_mobile/core/network/dio_client.dart';
import 'package:eventsync_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:eventsync_mobile/features/auth/domain/entities/user.dart';
import 'package:eventsync_mobile/features/auth/domain/repositories/auth_repository.dart';

/// Provides the auth repository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(dio: ref.watch(dioProvider));
});

/// Auth state: null = not logged in, User = logged in.
final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // On app start, try to restore session
    final repo = ref.read(authRepositoryProvider);
    final token = await repo.getStoredToken();
    if (token == null) return null;

    try {
      final user = await repo.getMe();
      return user;
    } on UnauthorizedException {
      await repo.clearSession();
      return null;
    } catch (_) {
      // Network error on startup — keep token, return null for now
      return null;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.login(email: email, password: password);
      return result.user;
    });
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? divisi,
    String? phone,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    return repo.register(
      name: name,
      email: email,
      password: password,
      divisi: divisi,
      phone: phone,
    );
  }

  Future<void> refreshUser() async {
    final repo = ref.read(authRepositoryProvider);
    try {
      final user = await repo.getMe();
      state = AsyncData(user);
    } catch (_) {
      // Keep current state on error
    }
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.logout();
    } catch (_) {}
    state = const AsyncData(null);
  }

  Future<void> forceLogout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.clearSession();
    state = const AsyncData(null);
  }
}

/// Convenience provider: is the user logged in?
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).valueOrNull != null;
});

/// Current user (non-null when logged in).
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});
