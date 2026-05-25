import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:eventsync_mobile/core/theme/app_colors.dart';
import 'package:eventsync_mobile/features/tasks/presentation/providers/task_provider.dart';
import 'package:eventsync_mobile/features/admin/presentation/providers/user_provider.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final int eventId;
  const TaskFormScreen({super.key, required this.eventId});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  
  DateTime? _tenggatWaktu;
  String _prioritas = 'sedang';
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tenggatWaktu ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.cardDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _tenggatWaktu = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_tenggatWaktu == null) {
      setState(() => _errorMessage = 'Tenggat waktu wajib diisi');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      
      // Step 1: Look up user by email
      final userRepository = ref.read(userRepositoryProvider);
      final searchResult = await userRepository.getUsers(search: email);
      
      if (searchResult.data == null || searchResult.data!.isEmpty) {
        setState(() {
          _errorMessage = 'Staf dengan email $email tidak ditemukan.';
          _isLoading = false;
        });
        return;
      }
      
      // Check exact email match
      final assignee = searchResult.data!.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception('Email tidak persis cocok. Mohon cek kembali.'),
      );

      // Step 2: Create task
      await ref.read(taskListNotifierProvider(TaskListParams(eventId: widget.eventId)).notifier).createTask(
        eventId: widget.eventId,
        assigneeId: assignee.id,
        judul: _judulController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        tenggatWaktu: _tenggatWaktu!,
        prioritas: _prioritas,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tugas berhasil ditambahkan')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Buat Tugas Baru'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withAlpha(80)),
                    ),
                    child: Text(_errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13)),
                  ),

                TextFormField(
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email Staf Penerima Tugas *',
                    prefixIcon: Icon(LucideIcons.atSign),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Email wajib diisi' : null,
                ),
                const Gap(8),
                const Text(
                  ' Email harus terdaftar sebagai user di dalam aplikasi',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                const Gap(24),

                TextFormField(
                  controller: _judulController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Judul Tugas *',
                    prefixIcon: Icon(LucideIcons.checkCircle),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Judul tugas wajib diisi' : null,
                ),
                const Gap(16),

                TextFormField(
                  controller: _deskripsiController,
                  textInputAction: TextInputAction.done,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Deskripsi Detail (Opsional)',
                    prefixIcon: Icon(LucideIcons.fileText),
                  ),
                ),
                const Gap(24),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prioritas', style: Theme.of(context).textTheme.titleSmall),
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _prioritas,
                                isExpanded: true,
                                dropdownColor: AppColors.cardDark,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                items: const [
                                  DropdownMenuItem(value: 'rendah', child: Text('Rendah')),
                                  DropdownMenuItem(value: 'sedang', child: Text('Sedang')),
                                  DropdownMenuItem(value: 'tinggi', child: Text('Tinggi')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _prioritas = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tenggat Waktu *', style: Theme.of(context).textTheme.titleSmall),
                          const Gap(8),
                          InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.glassBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.calendar, size: 18, color: AppColors.textSecondary),
                                  const Gap(8),
                                  Expanded(
                                    child: Text(
                                      _tenggatWaktu != null ? dateFormat.format(_tenggatWaktu!) : 'Pilih',
                                      style: TextStyle(
                                        color: _tenggatWaktu != null ? AppColors.textPrimary : AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Gap(40),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text('Buat Tugas & Assign'),
                  ),
                ),
                const Gap(24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
