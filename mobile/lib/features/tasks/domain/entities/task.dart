/// Task (Tugas) entity matching backend `tugas` table.
class Task {
  final int id;
  final int eventId;
  final int? rundownId;
  final String judul;
  final String? deskripsi;
  final int? assigneeId;
  final String? divisi;
  final String prioritas; // kritis, tinggi, sedang, rendah
  final String status; // belum, proses, selesai, terkendala
  final DateTime? deadline;
  final String? lampiranUrl;
  final String? catatan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relations (often included in GET /tugas API)
  final String? assigneeName;
  final String? rundownTitle;
  final String? eventName;

  const Task({
    required this.id,
    required this.eventId,
    this.rundownId,
    required this.judul,
    this.deskripsi,
    this.assigneeId,
    this.divisi,
    required this.prioritas,
    required this.status,
    this.deadline,
    this.lampiranUrl,
    this.catatan,
    this.createdAt,
    this.updatedAt,
    this.assigneeName,
    this.rundownTitle,
    this.eventName,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    // Parse assignee relation
    String? parsedAssigneeName;
    final assigneeJson = json['assignee'];
    if (assigneeJson is Map) {
      parsedAssigneeName = assigneeJson['name'] as String?;
    } else {
      parsedAssigneeName = json['assignee_name'] as String?;
    }

    return Task(
      id: json['id'] as int,
      eventId: json['event_id'] as int,
      rundownId: json['rundown_id'] as int?,
      judul: json['judul'] as String? ?? '',
      deskripsi: json['deskripsi'] as String?,
      assigneeId: json['assignee_id'] as int?,
      divisi: json['divisi'] as String?,
      prioritas: json['prioritas'] as String? ?? 'sedang',
      status: json['status'] as String? ?? 'belum',
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'].toString())
          : null,
      lampiranUrl: json['lampiran_url'] as String?,
      catatan: json['catatan'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      assigneeName: parsedAssigneeName,
      rundownTitle: json['rundown_title'] as String?,
      eventName: json['event_name'] as String?,
    );
  }
}
