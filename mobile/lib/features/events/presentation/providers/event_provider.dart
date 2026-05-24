import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eventsync_mobile/core/network/dio_client.dart';
import 'package:eventsync_mobile/features/events/data/repositories/event_repository_impl.dart';
import 'package:eventsync_mobile/features/events/domain/entities/event.dart';
import 'package:eventsync_mobile/features/events/domain/repositories/event_repository.dart';
import 'package:eventsync_mobile/features/auth/presentation/providers/auth_provider.dart';

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
  final user = ref.watch(currentUserProvider);
  final filterKetuaId = user?.role == 'ketua' ? user?.id : null;
  return EventListNotifier(ref.watch(eventRepositoryProvider), filterKetuaId);
});

class EventListNotifier extends StateNotifier<EventListState> {
  final EventRepository _repository;
  final int? _filterKetuaId;
  static const int _perPage = 10;

  EventListNotifier(this._repository, this._filterKetuaId) : super(const EventListState()) {
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
        ketuaId: _filterKetuaId,
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
        ketuaId: _filterKetuaId,
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

  Future<void> createEvent({
    required String namaEvent,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
    String? deskripsi,
    String? lokasi,
  }) async {
    try {
      final newEvent = await _repository.createEvent(
        namaEvent: namaEvent,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
        deskripsi: deskripsi,
        lokasi: lokasi,
      );
      
      // Add the new event to the top of the list
      state = state.copyWith(
        events: [newEvent, ...state.events],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(int id) async {
    try {
      await _repository.deleteEvent(id);
      
      // Remove the event from the list
      state = state.copyWith(
        events: state.events.where((e) => e.id != id).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// Provider for a single event detail.
final eventDetailProvider =
    FutureProvider.family<Event, int>((ref, id) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getEventDetail(id);
});
