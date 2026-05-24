/// Event entity matching backend `events` table.
class Event {
  final int id;
  final String namaEvent;
  final String? deskripsi;
  final String? lokasi;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final String status;
  final int ketuaId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Event({
    required this.id,
    required this.namaEvent,
    this.deskripsi,
    this.lokasi,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.status,
    required this.ketuaId,
    this.createdAt,
    this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int,
      namaEvent: json['nama_event'] as String? ?? '',
      deskripsi: json['deskripsi'] as String?,
      lokasi: json['lokasi'] as String?,
      tanggalMulai: DateTime.parse(json['tanggal_mulai'].toString()),
      tanggalSelesai: DateTime.parse(json['tanggal_selesai'].toString()),
      status: json['status'] as String? ?? 'draft',
      ketuaId: json['ketua_id'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}
