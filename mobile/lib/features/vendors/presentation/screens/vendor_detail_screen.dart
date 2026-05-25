import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:eventsync_mobile/core/theme/app_colors.dart';
import 'package:eventsync_mobile/shared/widgets/status_badge.dart';
import 'package:eventsync_mobile/features/vendors/domain/entities/vendor.dart';
import 'package:eventsync_mobile/features/vendors/presentation/providers/vendor_provider.dart';
import 'package:eventsync_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class VendorDetailScreen extends ConsumerWidget {
  final int vendorId;

  const VendorDetailScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorAsync = ref.watch(vendorDetailProvider(vendorId));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Detail Vendor'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final user = ref.watch(currentUserProvider);
              final isAdminOrKetua = user?.role == 'admin' || user?.role == 'ketua';
              if (!isAdminOrKetua) return const SizedBox.shrink();

              return PopupMenuButton<String>(
                color: AppColors.cardDark,
                onSelected: (value) async {
                  if (value == 'edit') {
                    final vendor = ref.read(vendorDetailProvider(vendorId)).valueOrNull;
                    if (vendor == null) return;

                    final namaCtrl = TextEditingController(text: vendor.namaVendor);
                    final kategoriCtrl = TextEditingController(text: vendor.kategori);
                    final kontakCtrl = TextEditingController(text: vendor.kontakPerson);

                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.cardDark,
                        title: const Text('Edit Vendor'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: namaCtrl,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: const InputDecoration(labelText: 'Nama Vendor'),
                              ),
                              const Gap(12),
                              TextField(
                                controller: kategoriCtrl,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: const InputDecoration(labelText: 'Layanan'),
                              ),
                              const Gap(12),
                              TextField(
                                controller: kontakCtrl,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: const InputDecoration(labelText: 'Kontak Person'),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Simpan', style: TextStyle(color: AppColors.primary)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      try {
                        await ref.read(vendorRepositoryProvider).updateVendor(
                          id: vendorId,
                          namaVendor: namaCtrl.text.trim(),
                          layanan: kategoriCtrl.text.trim(),
                          kontak: kontakCtrl.text.trim(),
                        );
                        ref.invalidate(vendorDetailProvider(vendorId));
                        ref.invalidate(vendorListProvider(vendor.eventId));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vendor berhasil diupdate')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gagal update vendor')),
                          );
                        }
                      }
                    }
                  } else if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.cardDark,
                        title: const Text('Hapus Vendor'),
                        content: const Text('Apakah Anda yakin ingin menghapus vendor ini?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      try {
                        await ref.read(vendorRepositoryProvider).deleteVendor(vendorId);
                        final vendor = ref.read(vendorDetailProvider(vendorId)).valueOrNull;
                        if (vendor != null) {
                          ref.invalidate(vendorListProvider(vendor.eventId));
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vendor berhasil dihapus')),
                          );
                          context.pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gagal menghapus vendor')),
                          );
                        }
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(LucideIcons.pencil, color: AppColors.textPrimary, size: 20),
                        Gap(12),
                        Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(LucideIcons.trash, color: AppColors.error, size: 20),
                        Gap(12),
                        Text('Hapus', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              );
            },
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
              const Gap(16),
              ElevatedButton(
                onPressed: () => ref.invalidate(vendorDetailProvider(vendorId)),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (vendor) => _VendorDetailContent(vendor: vendor),
      ),
    );
  }
}

class _VendorDetailContent extends StatelessWidget {
  final Vendor vendor;

  const _VendorDetailContent({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
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
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        vendor.kategori.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: vendor.status),
            ],
          ),
          const Gap(32),

          // Contact Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kontak Person',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.surfaceContainer,
                      child: Text(
                        vendor.picName.isNotEmpty ? vendor.picName.substring(0, 1).toUpperCase() : 'V',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vendor.picName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            vendor.picPhone,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final url = Uri.parse('tel:${vendor.picPhone}');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      icon: const Icon(LucideIcons.phone, color: AppColors.primary),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withAlpha(20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(24),

          // Notes
          if (vendor.notes != null && vendor.notes!.isNotEmpty) ...[
            const Text(
              'Catatan Tambahan',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: Text(
                vendor.notes!,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
