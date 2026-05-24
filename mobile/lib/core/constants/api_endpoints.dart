/// API endpoint constants matching the backend routes.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Users
  static const String users = '/users';
  static String user(int id) => '/users/$id';

  // Events
  static const String events = '/events';
  static String event(int id) => '/events/$id';

  // Vendors (nested under event)
  static String eventVendors(int eventId) => '/events/$eventId/vendors';
  static String vendor(int id) => '/vendors/$id';

  // Rundowns (nested under event)
  static String eventRundowns(int eventId) => '/events/$eventId/rundowns';
  static String rundown(int id) => '/rundowns/$id';

  // Tugas (nested under event)
  static String eventTugas(int eventId) => '/events/$eventId/tugas';
  static String tugas(int id) => '/tugas/$id';
  static String tugasStatus(int id) => '/tugas/$id/status';

  // Laporan
  static String eventLaporan(int eventId) => '/events/$eventId/laporan';

  // Upload
  static const String upload = '/upload';

  // Realtime / NoSQL
  static const String realtimeChecklist = '/realtime/checklist';
  static String realtimeEventChecklist(int eventId) =>
      '/realtime/events/$eventId/checklist';
  static String realtimeChecklistStatus(String id) =>
      '/realtime/checklist/$id/status';

  static const String realtimeChatMessages = '/realtime/chat/messages';
  static String realtimeEventChat(int eventId) =>
      '/realtime/events/$eventId/chat';

  static const String realtimeNotifikasi = '/realtime/notifikasi';
  static const String realtimeNotifikasiMe = '/realtime/notifikasi/me';
  static String realtimeNotifikasiRead(String id) =>
      '/realtime/notifikasi/$id/read';

  static const String realtimeRundownChanges = '/realtime/rundown-changes';
  static String realtimeEventRundownChanges(int eventId) =>
      '/realtime/events/$eventId/rundown-changes';

  static const String realtimeLogs = '/realtime/logs';
  static String realtimeEventLogs(int eventId) =>
      '/realtime/events/$eventId/logs';
}
