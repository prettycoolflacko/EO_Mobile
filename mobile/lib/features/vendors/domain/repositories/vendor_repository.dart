import 'package:eventsync_mobile/core/network/api_response.dart';
import 'package:eventsync_mobile/features/vendors/domain/entities/vendor.dart';

abstract class VendorRepository {
  Future<ApiResponse<List<Vendor>>> getVendorsByEvent(int eventId);
  Future<Vendor> getVendorDetail(int id);
}
