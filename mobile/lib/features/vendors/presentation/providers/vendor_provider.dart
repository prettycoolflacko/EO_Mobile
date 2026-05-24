import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eventsync_mobile/core/network/dio_client.dart';
import 'package:eventsync_mobile/features/vendors/data/repositories/vendor_repository_impl.dart';
import 'package:eventsync_mobile/features/vendors/domain/entities/vendor.dart';
import 'package:eventsync_mobile/features/vendors/domain/repositories/vendor_repository.dart';

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return VendorRepositoryImpl(dio: ref.watch(dioProvider));
});

/// Fetches the list of vendors for a specific event.
final vendorListProvider =
    FutureProvider.family<List<Vendor>, int>((ref, eventId) async {
  final repository = ref.watch(vendorRepositoryProvider);
  final response = await repository.getVendorsByEvent(eventId);
  return response.data ?? [];
});

/// Fetches a single vendor detail.
final vendorDetailProvider = FutureProvider.family<Vendor, int>((ref, id) async {
  final repository = ref.watch(vendorRepositoryProvider);
  return repository.getVendorDetail(id);
});
