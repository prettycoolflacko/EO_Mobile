import 'package:eventsync_mobile/core/network/api_response.dart';
import 'package:eventsync_mobile/features/rundown/domain/entities/rundown.dart';

abstract class RundownRepository {
  Future<ApiResponse<List<Rundown>>> getRundownsByEvent(int eventId);
  Future<Rundown> updateRundownStatus(int id, String status);

  Future<Rundown> createRundown({
    required int eventId,
    required String kegiatan,
    required DateTime waktuMulai,
    required DateTime waktuSelesai,
    String? pic,
  });
}
