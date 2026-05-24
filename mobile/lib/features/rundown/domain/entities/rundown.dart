/// Rundown entity matching backend `rundowns` table.
class Rundown {
  final int id;
  final int eventId;
  final String judulSesi;
  final String? deskripsi;
  final DateTime waktuMulai;
  final DateTime? _waktuSelesai;
  final int? picId;
  final String picName;
  final int? vendorId;
  final String? vendorName;
  final String status; // ditunda, berjalan, selesai, belum
  final int urutan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Rundown({
    required this.id,
    required this.eventId,
    required this.judulSesi,
    this.deskripsi,
    required this.waktuMulai,
    DateTime? waktuSelesai,
    this.picId,
    required this.picName,
    this.vendorId,
    this.vendorName,
    required this.status,
    required this.urutan,
    this.createdAt,
    this.updatedAt,
  }) : _waktuSelesai = waktuSelesai;

  // Compatibility getters for the UI screens
  String get namaKegiatan => judulSesi;
  String get pic => picName;
  String? get lokasi => null; // Rundown model doesn't have a lokasi column in DB
  DateTime get waktuSelesai => _waktuSelesai ?? waktuMulai;

  static DateTime _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2].split('.')[0]), // Handle fractional seconds if any
      );
    } catch (_) {
      return DateTime.tryParse(timeStr) ?? DateTime.now();
    }
  }

  factory Rundown.fromJson(Map<String, dynamic> json) {
    final startVal = json['waktu_mulai']?.toString() ?? '00:00:00';
    final endVal = json['waktu_selesai']?.toString();

    // Parse pic
    String parsedPicName = 'Tidak ada PIC';
    int? parsedPicId;
    final picJson = json['pic'];
    if (picJson != null) {
      if (picJson is Map) {
        parsedPicId = picJson['id'] as int?;
        parsedPicName = picJson['name']?.toString() ?? 'Tidak ada PIC';
      } else {
        parsedPicName = picJson.toString();
      }
    } else if (json['pic_id'] != null) {
      parsedPicId = json['pic_id'] as int?;
    }

    // Parse vendor
    String? parsedVendorName;
    int? parsedVendorId;
    final vendorJson = json['vendor'];
    if (vendorJson != null) {
      if (vendorJson is Map) {
        parsedVendorId = vendorJson['id'] as int?;
        parsedVendorName = vendorJson['nama_vendor']?.toString();
      }
    } else if (json['vendor_id'] != null) {
      parsedVendorId = json['vendor_id'] as int?;
    }

    return Rundown(
      id: json['id'] as int,
      eventId: json['event_id'] as int,
      judulSesi: json['judul_sesi'] as String? ?? json['nama_kegiatan'] as String? ?? '',
      deskripsi: json['deskripsi'] as String?,
      waktuMulai: _parseTime(startVal),
      waktuSelesai: endVal != null ? _parseTime(endVal) : null,
      picId: parsedPicId,
      picName: parsedPicName,
      vendorId: parsedVendorId,
      vendorName: parsedVendorName,
      status: json['status'] as String? ?? 'belum',
      urutan: json['urutan'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}
