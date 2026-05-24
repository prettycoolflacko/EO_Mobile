/// Notification entity mapping to backend schema.
class NotificationModel {
  final String id;
  final String tipe; // tugas, rundown, vendor, sistem
  final String judul;
  final String pesan;
  final int userId;
  final int eventId;
  final bool isRead;
  final DateTime createdAt;

  final int? _targetUserId;
  final String? _targetDivisi;

  const NotificationModel({
    required this.id,
    required this.tipe,
    required this.judul,
    required this.pesan,
    this.userId = 0,
    this.eventId = 0,
    this.isRead = false,
    required this.createdAt,
    int? targetUserId,
    String? targetDivisi,
  }) : _targetUserId = targetUserId,
       _targetDivisi = targetDivisi;

  int? get targetUserId => _targetUserId ?? userId;
  String? get targetDivisi => _targetDivisi;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      tipe: json['tipe'] as String? ?? 'sistem',
      judul: json['judul'] as String? ?? 'Notifikasi',
      pesan: json['pesan'] as String? ?? '',
      userId: json['user_id'] as int? ?? json['target_user_id'] as int? ?? 0,
      eventId: json['event_id'] as int? ?? 0,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
