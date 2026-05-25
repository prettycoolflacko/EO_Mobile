import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:eventsync_mobile/core/theme/app_colors.dart';
import 'package:eventsync_mobile/features/vendors/presentation/providers/vendor_provider.dart';

class VendorFormScreen extends ConsumerStatefulWidget {
  final int eventId;
  const VendorFormScreen({super.key, required this.eventId});

  @override
  ConsumerState<VendorFormScreen> createState() => _VendorFormScreenState();
}

class _VendorFormScreenState extends ConsumerState<VendorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _layananController = TextEditingController();
  final _kontakController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _namaController.dispose();
    _layananController.dispose();
    _kontakController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(vendorRepositoryProvider);
      
      await repository.createVendor(
        eventId: widget.eventId,
        namaVendor: _namaController.text.trim(),
        layanan: _layananController.text.trim(),
        kontak: _kontakController.text.trim(),
      );
      
      // Refresh the list
      ref.invalidate(vendorListProvider(widget.eventId));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vendor berhasil ditambahkan')),
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
        title: const Text('Tambah Vendor Baru'),
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
                    hintText: 'Nama Vendor *',
                    prefixIcon: Icon(LucideIcons.store),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nama vendor wajib diisi' : null,
                ),
                const Gap(16),

                TextFormField(
                  controller: _layananController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Layanan (Misal: Katering, Dekorasi) *',
                    prefixIcon: Icon(LucideIcons.briefcase),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Layanan wajib diisi' : null,
                ),
                const Gap(16),

                TextFormField(
                  controller: _kontakController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'Kontak Vendor (Opsional)',
                    prefixIcon: Icon(LucideIcons.phone),
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
                        : const Text('Tambah Vendor'),
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
