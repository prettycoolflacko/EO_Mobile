import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:eventsync_mobile/core/theme/app_colors.dart';
import 'package:eventsync_mobile/shared/widgets/status_badge.dart';
import 'package:eventsync_mobile/features/vendors/domain/entities/vendor.dart';
import 'package:eventsync_mobile/features/vendors/presentation/providers/vendor_provider.dart';

class VendorListScreen extends ConsumerWidget {
  final int eventId;

  const VendorListScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorAsync = ref.watch(vendorListProvider(eventId));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Daftar Vendor'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () => ref.invalidate(vendorListProvider(eventId)),
          ),
        ],
      ),
      body: vendorAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                const Icon(LucideIcons.alertCircle,
                  color: AppColors.error, size: 48),
              const Gap(16),
              Text(err.toString(),
                  style: const TextStyle(color: AppColors.error)),
            ],
          ),
        ),
        data: (vendors) {
          if (vendors.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(LucideIcons.store,
                      size: 64, color: AppColors.textSecondary),
                  Gap(16),
                  Text('Belum ada vendor',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: vendors.length,
            separatorBuilder: (_, __) => const Gap(12),
            itemBuilder: (context, index) {
              final vendor = vendors[index];
              return _VendorCard(vendor: vendor);
            },
          );
        },
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final Vendor vendor;

  const _VendorCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/vendors/detail/${vendor.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.namaVendor,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const Gap(4),
                      Text(
                        vendor.kategori.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: vendor.status),
              ],
            ),
            const Gap(16),
            Row(
              children: [
                const Icon(LucideIcons.user,
                    size: 16, color: AppColors.textSecondary),
                const Gap(8),
                Text(
                  vendor.picName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
