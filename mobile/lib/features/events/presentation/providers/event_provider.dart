import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eventsync_mobile/core/network/dio_client.dart';
import 'package:eventsync_mobile/features/events/data/repositories/event_repository_impl.dart';
import 'package:eventsync_mobile/features/events/domain/entities/event.dart';
import 'package:eventsync_mobile/features/events/domain/repositories/event_repository.dart';

/// Provides the EventRepository.
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl(dio: ref.watch(dioProvider));
});

/// State class for paginated event list.
class EventListState {
  final List<Event> events;
  final bool isLoading;
  final bool hasNextPage;
  final int currentPage;
  final String? errorMessage;
  final String? searchQuery;
  final String? statusFilter;

  const EventListState({
    this.events = const [],
    this.isLoading = false,
    this.hasNextPage = true,
    this.currentPage = 1,
    this.errorMessage,
    this.searchQuery,
    this.statusFilter,
  });

  EventListState copyWith({
    List<Event>? events,
    bool? isLoading,
    bool? hasNextPage,
    int? currentPage,
    String? errorMessage,
    String? searchQuery,
    String? statusFilter,
  }) {
    return EventListState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

/// Provider for managing the paginated list of events.
final eventListNotifierProvider =
    StateNotifierProvider<EventListNotifier, EventListState>((ref) {
  return EventListNotifier(ref.watch(eventRepositoryProvider));
});

class EventListNotifier extends StateNotifier<EventListState> {
  final EventRepository _repository;
  static const int _perPage = 10;

  EventListNotifier(this._repository) : super(const EventListState()) {
    fetchFirstPage();
  }

  Future<void> fetchFirstPage({String? search, String? status}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 1,
      searchQuery: search ?? state.searchQuery,
      statusFilter: status ?? state.statusFilter,
    );

    try {
      final response = await _repository.getEvents(
        page: 1,
        perPage: _perPage,
        search: state.searchQuery,
        status: state.statusFilter,
      );

      state = state.copyWith(
        isLoading: false,
        events: response.data ?? [],
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
      final response = await _repository.getEvents(
        page: nextPage,
        perPage: _perPage,
        search: state.searchQuery,
        status: state.statusFilter,
      );

      final newEvents = response.data ?? [];

      state = state.copyWith(
        isLoading: false,
        currentPage: nextPage,
        events: [...state.events, ...newEvents],
        hasNextPage: response.meta?.hasNextPage ?? false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(), // Provide user-friendly message via AppException later
      );
    }
  }
}

/// Provider for a single event detail.
final eventDetailProvider =
    FutureProvider.family<Event, int>((ref, id) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getEventDetail(id);
});
