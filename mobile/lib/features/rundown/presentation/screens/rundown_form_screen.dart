import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import 'package:eventsync_mobile/core/theme/app_colors.dart';
import 'package:eventsync_mobile/features/rundown/presentation/providers/rundown_provider.dart';

class RundownFormScreen extends ConsumerStatefulWidget {
  final int eventId;
  const RundownFormScreen({super.key, required this.eventId});

  @override
  ConsumerState<RundownFormScreen> createState() => _RundownFormScreenState();
}

class _RundownFormScreenState extends ConsumerState<RundownFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kegiatanController = TextEditingController();
  final _picController = TextEditingController();
  
  TimeOfDay? _waktuMulai;
  TimeOfDay? _waktuSelesai;
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _kegiatanController.dispose();
    _picController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isMulai) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isMulai 
        ? (_waktuMulai ?? TimeOfDay.now()) 
        : (_waktuSelesai ?? (_waktuMulai ?? TimeOfDay.now())),
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
      setState(() {
        if (isMulai) {
          _waktuMulai = picked;
        } else {
          _waktuSelesai = picked;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_waktuMulai == null || _waktuSelesai == null) {
      setState(() => _errorMessage = 'Waktu mulai dan selesai wajib diisi');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(rundownRepositoryProvider);
      
      // Convert TimeOfDay to dummy DateTime for API (API only needs time part or full ISO depending on backend,
      // but usually for rundown it's full datetime. Let's assume today's date + selected time)
      final now = DateTime.now();
      final mulaiDT = DateTime(now.year, now.month, now.day, _waktuMulai!.hour, _waktuMulai!.minute);
      final selesaiDT = DateTime(now.year, now.month, now.day, _waktuSelesai!.hour, _waktuSelesai!.minute);

      await repository.createRundown(
        eventId: widget.eventId,
        kegiatan: _kegiatanController.text.trim(),
        waktuMulai: mulaiDT,
        waktuSelesai: selesaiDT,
        pic: _picController.text.trim(),
      );
      
      // Refresh the list
      ref.invalidate(rundownListProvider(widget.eventId));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rundown berhasil ditambahkan')),
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
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Tambah Rundown Baru'),
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
                  controller: _kegiatanController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Nama Kegiatan *',
                    prefixIcon: Icon(Icons.event_note_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nama kegiatan wajib diisi' : null,
                ),
                const Gap(16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Waktu Mulai *', style: Theme.of(context).textTheme.titleSmall),
                          const Gap(8),
                          InkWell(
                            onTap: () => _selectTime(context, true),
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
                                  const Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
                                  const Gap(8),
                                  Expanded(
                                    child: Text(
                                      _waktuMulai != null ? _waktuMulai!.format(context) : 'Pilih',
                                      style: TextStyle(
                                        color: _waktuMulai != null ? AppColors.textPrimary : AppColors.textSecondary,
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
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Waktu Selesai *', style: Theme.of(context).textTheme.titleSmall),
                          const Gap(8),
                          InkWell(
                            onTap: () => _selectTime(context, false),
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
                                  const Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
                                  const Gap(8),
                                  Expanded(
                                    child: Text(
                                      _waktuSelesai != null ? _waktuSelesai!.format(context) : 'Pilih',
                                      style: TextStyle(
                                        color: _waktuSelesai != null ? AppColors.textPrimary : AppColors.textSecondary,
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
                const Gap(16),

                TextFormField(
                  controller: _picController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'PIC / Penanggung Jawab (Opsional)',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
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
                        : const Text('Tambah Rundown'),
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
