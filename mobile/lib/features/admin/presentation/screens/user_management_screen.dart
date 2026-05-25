import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:eventsync_mobile/core/theme/app_colors.dart';
import 'package:eventsync_mobile/features/admin/presentation/providers/user_provider.dart';
import 'package:eventsync_mobile/features/auth/domain/entities/user.dart';
import 'package:eventsync_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:eventsync_mobile/core/network/dio_client.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  Set<int> _allowedStaffIds = {};
  bool _isLoadingAllowedStaff = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllowedStaffIds();
    });
  }

  Future<void> _loadAllowedStaffIds() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser?.role != 'ketua') return;

    setState(() => _isLoadingAllowedStaff = true);
    try {
      final dio = ref.read(dioProvider);
      
      final eventsRes = await dio.get('/api/v1/events', queryParameters: {
        'ketua_id': currentUser!.id,
        'per_page': 100, // max 100 allowed by backend validation
      });
      final events = eventsRes.data['data']['events'] as List;
      final myEventIds = events.map((e) => e['id'] as int).toSet();

      final staffIds = <int>{};
      for (final eventId in myEventIds) {
        try {
          final tasksRes = await dio.get('/api/v1/events/$eventId/tugas', queryParameters: {'per_page': 100}); // max 100 allowed by backend validation
          final tasks = tasksRes.data['data']['tugas'] as List;
          for (final t in tasks) {
            if (t['assignee_id'] != null) {
              final val = t['assignee_id'];
              staffIds.add(val is int ? val : int.parse(val.toString()));
            }
          }
        } catch (e) {
          debugPrint('Failed to load tasks for event $eventId: $e');
        }
      }

      if (mounted) {
        setState(() {
          _allowedStaffIds = staffIds;
        });
      }
    } catch (e) {
      debugPrint('Failed to load allowed staff: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingAllowedStaff = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(userListNotifierProvider.notifier).fetchNextPage();
    }
  }

  void _onSearchChanged(String value) {
    ref.read(userListNotifierProvider.notifier).fetchFirstPage(search: value);
  }

  Future<void> _changeDivisi(User user) async {
    final currentUser = ref.read(currentUserProvider);
    
    // Validasi untuk ketua: hanya bisa ubah divisi jika staff ada di projectnya
    if (currentUser?.role == 'ketua') {
      if (!_allowedStaffIds.contains(user.id)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda hanya bisa mengubah divisi staff yang tergabung dalam event Anda.')),
          );
        }
        return;
      }
    }

    final controller = TextEditingController(text: user.divisi);
    final newDivisi = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Ubah Divisi'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Masukkan nama divisi...',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Simpan', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (newDivisi != null && newDivisi != user.divisi) {
      try {
        await ref.read(userListNotifierProvider.notifier).updateUserDivisi(user.id, newDivisi);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Divisi berhasil diubah menjadi $newDivisi')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengubah divisi')),
          );
        }
      }
    }
  }

  Future<void> _changeRole(User user) async {
    final newRole = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Ubah Role User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Admin', style: TextStyle(color: AppColors.textPrimary)),
              leading: Radio<String>(
                value: 'admin',
                groupValue: user.role,
                onChanged: (v) => Navigator.pop(ctx, v),
                activeColor: AppColors.primary,
              ),
            ),
            ListTile(
              title: const Text('Ketua', style: TextStyle(color: AppColors.textPrimary)),
              leading: Radio<String>(
                value: 'ketua',
                groupValue: user.role,
                onChanged: (v) => Navigator.pop(ctx, v),
                activeColor: AppColors.primary,
              ),
            ),
            ListTile(
              title: const Text('Staf', style: TextStyle(color: AppColors.textPrimary)),
              leading: Radio<String>(
                value: 'staf',
                groupValue: user.role,
                onChanged: (v) => Navigator.pop(ctx, v),
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );

    if (newRole != null && newRole != user.role) {
      try {
        await ref.read(userListNotifierProvider.notifier).updateUserRole(user.id, newRole);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Role berhasil diubah menjadi $newRole')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengubah role')),
          );
        }
      }
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Hapus User'),
        content: Text('Apakah Anda yakin ingin menghapus user ${user.name}?'),
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

    if (confirm == true) {
      try {
        await ref.read(userListNotifierProvider.notifier).deleteUser(user.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User ${user.name} berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus user. Pastikan tidak ada data yang bergantung kepadanya.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userListNotifierProvider);
    final currentUser = ref.watch(currentUserProvider);
    
    final displayedUsers = currentUser?.role == 'ketua'
        ? state.users.where((u) => _allowedStaffIds.contains(u.id)).toList()
        : state.users;
        
    // Cek jika filter mengosongkan list tapi masih ada data di next page, auto-fetch
    if (currentUser?.role == 'ketua' && !_isLoadingAllowedStaff && displayedUsers.isEmpty && state.hasNextPage && !state.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userListNotifierProvider.notifier).fetchNextPage();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(currentUser?.role == 'admin' ? 'Kelola User' : 'Kelola Staff & Divisi'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari nama atau email...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (state.errorMessage != null && state.users.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: (state.isLoading && state.users.isEmpty) || _isLoadingAllowedStaff
                ? const Center(child: CircularProgressIndicator())
                : displayedUsers.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada user ditemukan',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: displayedUsers.length + (state.hasNextPage ? 1 : 0),
                        separatorBuilder: (_, __) => const Gap(12),
                        itemBuilder: (context, index) {
                          if (index == displayedUsers.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final user = displayedUsers[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withAlpha(50),
                                child: Text(
                                  user.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: AppColors.primary),
                                ),
                              ),
                              title: Text(
                                user.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Gap(4),
                                  Text(user.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                  const Gap(4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withAlpha(30),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          user.role.toUpperCase(),
                                          style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      if (user.divisi != null) ...[
                                        const Gap(8),
                                        Text('• ${user.divisi}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                                color: AppColors.cardDark,
                                onSelected: (value) {
                                  if (value == 'divisi') _changeDivisi(user);
                                  if (value == 'role') _changeRole(user);
                                  if (value == 'delete') _deleteUser(user);
                                },
                                itemBuilder: (context) {
                                  final currentUser = ref.read(currentUserProvider);
                                  final isAdmin = currentUser?.role == 'admin';

                                  return [
                                    const PopupMenuItem(
                                      value: 'divisi',
                                      child: Row(
                                        children: [
                                          Icon(Icons.groups_outlined, color: AppColors.textPrimary, size: 20),
                                          Gap(12),
                                          Text('Ubah Divisi', style: TextStyle(color: AppColors.textPrimary)),
                                        ],
                                      ),
                                    ),
                                    if (isAdmin) ...[
                                      const PopupMenuItem(
                                        value: 'role',
                                        child: Row(
                                          children: [
                                            Icon(Icons.admin_panel_settings_outlined, color: AppColors.textPrimary, size: 20),
                                            Gap(12),
                                            Text('Ubah Role', style: TextStyle(color: AppColors.textPrimary)),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                            Gap(12),
                                            Text('Hapus User', style: TextStyle(color: AppColors.error)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ];
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
