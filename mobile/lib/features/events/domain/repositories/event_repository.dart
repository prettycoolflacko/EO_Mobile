import 'package:eventsync_mobile/core/network/api_response.dart';
import 'package:eventsync_mobile/features/events/domain/entities/event.dart';

abstract class EventRepository {
  Future<ApiResponse<List<Event>>> getEvents({
    int page = 1,
    int perPage = 10,
    String? search,
    String? status,
    int? ketuaId,
  });

  Future<Event> getEventDetail(int id);

  Future<Event> createEvent({
    required String namaEvent,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
    String? deskripsi,
    String? lokasi,
  });

  Future<void> deleteEvent(int id);
}
