import 'package:dio/dio.dart';

import 'package:eventsync_mobile/core/constants/api_endpoints.dart';
import 'package:eventsync_mobile/core/network/api_response.dart';
import 'package:eventsync_mobile/core/network/dio_client.dart';
import 'package:eventsync_mobile/features/vendors/domain/entities/vendor.dart';
import 'package:eventsync_mobile/features/vendors/domain/repositories/vendor_repository.dart';

class VendorRepositoryImpl implements VendorRepository {
  final Dio _dio;

  VendorRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ApiResponse<List<Vendor>>> getVendorsByEvent(int eventId) async {
    try {
      final response = await _dio.get(ApiEndpoints.eventVendors(eventId));
      return ApiResponse<List<Vendor>>.fromJson(
        response.data,
        (json) => (json['vendors'] as List)
            .map((e) => Vendor.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<Vendor> getVendorDetail(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.vendor(id));
      return Vendor.fromJson(response.data['data']['vendor'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
