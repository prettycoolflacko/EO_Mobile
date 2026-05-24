import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eventsync_mobile/core/network/dio_client.dart';
import 'package:eventsync_mobile/features/rundown/data/repositories/rundown_repository_impl.dart';
import 'package:eventsync_mobile/features/rundown/domain/entities/rundown.dart';
import 'package:eventsync_mobile/features/rundown/domain/repositories/rundown_repository.dart';

final rundownRepositoryProvider = Provider<RundownRepository>((ref) {
  return RundownRepositoryImpl(dio: ref.watch(dioProvider));
});

/// Fetches the list of rundowns for a specific event.
final rundownListProvider =
    FutureProvider.family<List<Rundown>, int>((ref, eventId) async {
  final repository = ref.watch(rundownRepositoryProvider);
  final response = await repository.getRundownsByEvent(eventId);
  return response.data ?? [];
});
