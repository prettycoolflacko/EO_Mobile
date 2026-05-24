/// Vendor entity matching backend `vendors` table.
class Vendor {
  final int id;
  final int eventId;
  final String namaVendor;
  final String kategori; // catering, sound_system, dekorasi, dll.
  final String kontakPerson;
  final String telepon;
  final String? email;
  final String? alamat;
  final String? kontrakUrl;
  final String status; // aktif, selesai, batal
  final String? catatan;
  final DateTime? createdAt;

  const Vendor({
    required this.id,
    required this.eventId,
    required this.namaVendor,
    required this.kategori,
    required this.kontakPerson,
    required this.telepon,
    this.email,
    this.alamat,
    this.kontrakUrl,
    required this.status,
    this.catatan,
    this.createdAt,
  });

  // Compatibility getters for the UI screens
  String get picName => kontakPerson;
  String get picPhone => telepon;
  String? get notes => catatan;

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as int,
      eventId: json['event_id'] as int,
      namaVendor: json['nama_vendor'] as String? ?? '',
      kategori: json['kategori'] as String? ?? '',
      kontakPerson: json['kontak_person'] as String? ?? json['pic_name'] as String? ?? '',
      telepon: json['telepon'] as String? ?? json['pic_phone'] as String? ?? '',
      email: json['email'] as String?,
      alamat: json['alamat'] as String?,
      kontrakUrl: json['kontrak_url'] as String?,
      status: json['status'] as String? ?? 'aktif',
      catatan: json['catatan'] as String? ?? json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
