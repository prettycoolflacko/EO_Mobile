import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eventsync_mobile/core/network/dio_client.dart';
import 'package:eventsync_mobile/features/admin/data/repositories/user_repository_impl.dart';
import 'package:eventsync_mobile/features/admin/domain/repositories/user_repository.dart';
import 'package:eventsync_mobile/features/auth/domain/entities/user.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(dio: ref.watch(dioProvider));
});

class UserListState {
  final List<User> users;
  final bool isLoading;
  final bool hasNextPage;
  final int currentPage;
  final String? errorMessage;
  final String? searchQuery;

  const UserListState({
    this.users = const [],
    this.isLoading = false,
    this.hasNextPage = true,
    this.currentPage = 1,
    this.errorMessage,
    this.searchQuery,
  });

  UserListState copyWith({
    List<User>? users,
    bool? isLoading,
    bool? hasNextPage,
    int? currentPage,
    String? errorMessage,
    String? searchQuery,
  }) {
    return UserListState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final userListNotifierProvider =
    StateNotifierProvider<UserListNotifier, UserListState>((ref) {
  return UserListNotifier(ref.watch(userRepositoryProvider));
});

class UserListNotifier extends StateNotifier<UserListState> {
  final UserRepository _repository;
  static const int _perPage = 20;

  UserListNotifier(this._repository) : super(const UserListState()) {
    fetchFirstPage();
  }

  Future<void> fetchFirstPage({String? search}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 1,
      searchQuery: search ?? state.searchQuery,
    );

    try {
      final response = await _repository.getUsers(
        page: 1,
        perPage: _perPage,
        search: state.searchQuery,
      );

      state = state.copyWith(
        isLoading: false,
        users: response.data ?? [],
        hasNextPage: response.meta?.hasNextPage ?? false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasNextPage) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getUsers(
        page: nextPage,
        perPage: _perPage,
        search: state.searchQuery,
      );

      final newUsers = response.data ?? [];

      state = state.copyWith(
        isLoading: false,
        currentPage: nextPage,
        users: [...state.users, ...newUsers],
        hasNextPage: response.meta?.hasNextPage ?? false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateUserRole(int id, String newRole) async {
    try {
      final updatedUser = await _repository.updateUserRole(id, newRole);
      final index = state.users.indexWhere((u) => u.id == id);
      if (index != -1) {
        final newUsers = List<User>.from(state.users);
        newUsers[index] = updatedUser;
        state = state.copyWith(users: newUsers);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserDivisi(int id, String divisi) async {
    try {
      final updatedUser = await _repository.updateUserDivisi(id, divisi);
      final index = state.users.indexWhere((u) => u.id == id);
      if (index != -1) {
        final newUsers = List<User>.from(state.users);
        newUsers[index] = updatedUser;
        state = state.copyWith(users: newUsers);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _repository.deleteUser(id);
      state = state.copyWith(
        users: state.users.where((u) => u.id != id).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
