import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import 'package:eventsync_mobile/core/theme/app_colors.dart';
import 'package:eventsync_mobile/core/errors/app_exception.dart';
import 'package:eventsync_mobile/features/events/presentation/providers/event_provider.dart';

class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key});

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_tanggalMulai ?? DateTime.now())
        : (_tanggalSelesai ?? _tanggalMulai ?? DateTime.now());
        
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
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
        if (isStart) {
          _tanggalMulai = picked;
          // Ensure end date is not before start date
          if (_tanggalSelesai != null && _tanggalSelesai!.isBefore(picked)) {
            _tanggalSelesai = picked;
          }
        } else {
          _tanggalSelesai = picked;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_tanggalMulai == null || _tanggalSelesai == null) {
      setState(() => _errorMessage = 'Tanggal mulai dan selesai wajib diisi');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(eventListNotifierProvider.notifier).createEvent(
        namaEvent: _namaController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
        lokasi: _lokasiController.text.trim(),
        tanggalMulai: _tanggalMulai!,
        tanggalSelesai: _tanggalSelesai!,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event berhasil dibuat')),
        );
        context.pop();
      }
    } on ValidationException catch (e) {
      setState(() => _errorMessage = e.errors?.first.message ?? e.message);
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'Terjadi kesalahan. Coba lagi.');
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
        title: const Text('Buat Event Baru'),
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
                  controller: _namaController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Nama Event *',
                    prefixIcon: Icon(Icons.event_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nama event wajib diisi' : null,
                ),
                const Gap(16),

                TextFormField(
                  controller: _deskripsiController,
                  textInputAction: TextInputAction.next,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Deskripsi (Opsional)',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const Gap(16),

                TextFormField(
                  controller: _lokasiController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'Lokasi (Opsional)',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const Gap(24),

                Text('Jadwal Pelaksanaan', style: Theme.of(context).textTheme.titleSmall),
                const Gap(12),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.glassBorder),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tanggal Mulai *', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              const Gap(4),
                              Text(
                                _tanggalMulai != null ? dateFormat.format(_tanggalMulai!) : 'Pilih Tanggal',
                                style: TextStyle(color: _tanggalMulai != null ? AppColors.textPrimary : AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.glassBorder),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tanggal Selesai *', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              const Gap(4),
                              Text(
                                _tanggalSelesai != null ? dateFormat.format(_tanggalSelesai!) : 'Pilih Tanggal',
                                style: TextStyle(color: _tanggalSelesai != null ? AppColors.textPrimary : AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
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
                        : const Text('Buat Event'),
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
