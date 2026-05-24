/// Chat Message entity matching backend schema.
class ChatMessage {
  final String id; // MongoDB ObjectId
  final int eventId;
  final String? divisi;
  final int senderId;
  final String senderName;
  final String pesan;
  final String? fileUrl;
  final String tipe; // text, gambar, file
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.eventId,
    this.divisi,
    required this.senderId,
    required this.senderName,
    required this.pesan,
    this.fileUrl,
    required this.tipe,
    required this.createdAt,
  });

  // Compatibility getters for the UI screens
  String? get lampiranUrl => fileUrl;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      eventId: json['event_id'] as int,
      divisi: json['divisi'] as String?,
      senderId: json['pengirim_id'] as int? ?? json['sender_id'] as int? ?? 0,
      senderName: json['pengirim_nama'] as String? ?? json['sender_name'] as String? ?? 'User',
      pesan: json['pesan'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? json['lampiran_url'] as String?,
      tipe: json['tipe'] as String? ?? 'text',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
