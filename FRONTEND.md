# Frontend Documentation — EventSync

> Panduan lengkap untuk mengembangkan frontend EventSync dengan semua fitur dan endpoint yang diperlukan.

**Versi:** 1.0  
**Status:** Aktif  
**Last Updated:** May 24, 2026

---

## 📋 Daftar Isi

1. [Overview](#overview)
2. [Fitur per Role](#fitur-per-role)
3. [Halaman dan Komponen](#halaman-dan-komponen)
4. [Endpoint API Lengkap](#endpoint-api-lengkap)
5. [Request/Response Format](#requestresponse-format)
6. [Panduan Implementasi](#panduan-implementasi)
7. [Authentication Flow](#authentication-flow)
8. [Best Practices](#best-practices)

---

## Overview

**EventSync Frontend** adalah aplikasi web responsif yang memungkinkan koordinasi acara secara realtime. Frontend mendukung 3 role utama dengan akses berbeda:
- **Admin**: Manajemen penuh sistem
- **Ketua**: Manajemen event dan koordinasi
- **Staf**: Checklist tugas dan komunikasi

**Tech Stack Rekomendasi:**
- React 18+ atau Vue 3 (pilih sesuai preferensi tim)
- TypeScript (opsional, tapi recommended)
- Axios atau Fetch API untuk HTTP
- Redux/Vuex atau Context API untuk state management
- Socket.io atau Polling untuk realtime (opsional, bisa fallback polling)
- Tailwind CSS atau Material UI untuk styling

---

## Fitur per Role

### Admin
- ✅ Manajemen user (create, read, update, delete, ubah role)
- ✅ Manajemen event (full CRUD)
- ✅ Manajemen vendor, rundown, tugas, laporan per event
- ✅ View checklist realtime semua event
- ✅ View logs koordinasi semua event
- ✅ Broadcast notifikasi ke users

### Ketua
- ✅ CRUD event (create, update status)
- ✅ CRUD vendor, rundown, tugas per event
- ✅ Lihat dan buat laporan event
- ✅ View checklist realtime event yang dipimpin
- ✅ View logs koordinasi event
- ✅ Broadcast notifikasi ke team
- ✅ Update rundown realtime

### Staf
- ✅ Lihat event yang ada tugas
- ✅ Lihat tugas yang di-assign
- ✅ Update status tugas milik sendiri
- ✅ Chat per event (divisi)
- ✅ Lihat notifikasi personal
- ✅ Checklist item dalam rundown
- ✅ Upload file untuk tugas/laporan

---

## Halaman dan Komponen

### Halaman Publik
- **Login Page** — Autentikasi user
- **Register Page** — Registrasi user (role: staf)

### Halaman Admin
- **User Management** — List, create, edit, delete, ubah role user
- **Event Management** — Dashboard event semua
- **System Dashboard** — Statistik, realtime checklist, koordinasi log

### Halaman Ketua
- **Dashboard Ketua** — Event yg dipimpin, statistik
- **Event Detail** — Vendor, rundown, tugas, laporan per event
- **Team Coordination** — Chat, notifikasi, rundown changes
- **Reports** — Lihat & buat laporan per event

### Halaman Staf
- **Dashboard Staf** — Event dengan tugas, notifikasi
- **My Tasks** — List tugas assigned, status, deadline
- **Task Detail** — Lihat detail, update status, upload file
- **Event Chat** — Komunikasi per divisi/event
- **Notifications** — Notifikasi personal

### Komponen Reusable
- **Navbar/Header** — User profile, logout, breadcrumb
- **Sidebar Navigation** — Menu sesuai role
- **Event Card** — Preview event, status, count
- **Task Card** — Task item dengan status badge
- **Modal Dialog** — Form create/edit
- **Pagination** — List navigation
- **Filter/Search** — Cari dan filter
- **File Upload** — Single/multiple file upload
- **Status Badge** — Visual status indicators
- **Loading Spinner** — Loading state
- **Error Alert** — Error message display
- **Success Toast** — Success notification
- **Empty State** — No data message

---

## Endpoint API Lengkap

### Base URL
```
http://localhost:8080/api/v1
atau
https://your-domain.com/api/v1
```

### Authorization Header
```
Authorization: Bearer <token>
```

Semua endpoint (kecuali `/auth/register` dan `/auth/login`) memerlukan token di header.

---

### 🔐 AUTH — Autentikasi

#### POST /auth/register
Daftar user baru sebagai staf.

**Request:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123",
  "divisi": "Sound System"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Registrasi berhasil",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "staf",
      "divisi": "Sound System",
      "is_active": true
    }
  }
}
```

#### POST /auth/login
Login dengan email dan password.

**Request:**
```json
{
  "email": "admin@gmail.com",
  "password": "admin123"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "user": {
      "id": 1,
      "name": "Admin User",
      "email": "admin@gmail.com",
      "role": "admin",
      "divisi": null,
      "is_active": true
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### GET /auth/me
Ambil profil user yang sedang login.

**Response (200):**
```json
{
  "success": true,
  "message": "Profil user berhasil diambil",
  "data": {
    "user": {
      "id": 1,
      "name": "Admin User",
      "email": "admin@gmail.com",
      "role": "admin",
      "divisi": null,
      "phone": "08123456789",
      "avatar_url": "https://...",
      "is_active": true,
      "created_at": "2025-01-01T00:00:00.000Z"
    }
  }
}
```

#### POST /auth/logout
Logout dan invalidate token.

**Response (200):**
```json
{
  "success": true,
  "message": "Logout berhasil"
}
```

---

### 👥 USERS — Manajemen User (Admin/Ketua Only)

#### GET /users
List semua user (paginated).

**Query Params:**
- `page` (default: 1)
- `per_page` (default: 10)
- `q` — Cari berdasarkan name/email
- `role` — Filter by role (admin, ketua, staf)
- `divisi` — Filter by divisi
- `sort_by` — Sort field (name, email, created_at)
- `order` — ASC atau DESC

**Response (200):**
```json
{
  "success": true,
  "message": "Daftar user berhasil diambil",
  "data": {
    "users": [
      {
        "id": 1,
        "name": "Admin User",
        "email": "admin@gmail.com",
        "role": "admin",
        "divisi": null,
        "phone": "08123456789",
        "is_active": true,
        "created_at": "2025-01-01T00:00:00.000Z"
      }
    ]
  },
  "meta": {
    "page": 1,
    "per_page": 10,
    "total": 50,
    "total_pages": 5
  }
}
```

#### GET /users/:id
Ambil detail user by ID.

**Response (200):**
```json
{
  "success": true,
  "message": "Detail user berhasil diambil",
  "data": {
    "user": {
      "id": 1,
      "name": "Staf User",
      "email": "staf@gmail.com",
      "role": "staf",
      "divisi": "Sound System",
      "phone": "08123456789",
      "avatar_url": "https://...",
      "is_active": true,
      "created_at": "2025-01-01T00:00:00.000Z"
    }
  }
}
```

#### PUT /users/:id
Update user profile (Admin/Ketua Only).

**Request:**
```json
{
  "name": "Updated Name",
  "phone": "08987654321",
  "divisi": "Dekorasi"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "User berhasil diperbarui",
  "data": {
    "user": { /* updated user */ }
  }
}
```

#### PATCH /users/:id/role
Ubah role user (Admin Only).

**Request:**
```json
{
  "role": "ketua"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Role user berhasil diperbarui",
  "data": {
    "user": { /* updated user */ }
  }
}
```

#### DELETE /users/:id
Hapus user (Admin Only).

**Response (204):** No content (atau 200 dengan success message)

---

### 📅 EVENTS — Manajemen Event

#### GET /events
List event (untuk staff, hanya event dengan tugas assigned).

**Query Params:**
- `page`, `per_page`
- `q` — Cari nama/lokasi
- `status` — draft, aktif, selesai, batal
- `ketua_id` — Filter by ketua
- `tanggal_mulai_from`, `tanggal_mulai_to` — Date range
- `sort_by` — created_at, tanggal_mulai, nama_event
- `order` — ASC, DESC

**Response (200):**
```json
{
  "success": true,
  "message": "Daftar event berhasil diambil",
  "data": {
    "events": [
      {
        "id": 1,
        "nama_event": "Konser Musik 2025",
        "deskripsi": "Konser musik tahunan...",
        "lokasi": "Jakarta Convention Center",
        "tanggal_mulai": "2025-06-01",
        "tanggal_selesai": "2025-06-02",
        "status": "aktif",
        "ketua_id": 2,
        "ketua": {
          "id": 2,
          "name": "Ketua Event",
          "email": "ketua@gmail.com",
          "role": "ketua"
        },
        "created_at": "2025-01-01T00:00:00.000Z",
        "updated_at": "2025-01-15T10:00:00.000Z"
      }
    ]
  },
  "meta": { /* pagination */ }
}
```

#### POST /events
Buat event baru (Admin/Ketua Only).

**Request:**
```json
{
  "nama_event": "Konser Musik 2025",
  "deskripsi": "Deskripsi event...",
  "lokasi": "Jakarta Convention Center",
  "tanggal_mulai": "2025-06-01",
  "tanggal_selesai": "2025-06-02",
  "status": "draft",
  "ketua_id": 2
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Event berhasil dibuat",
  "data": {
    "event": { /* event object */ }
  }
}
```

#### GET /events/:id
Ambil detail event dengan statistik.

**Response (200):**
```json
{
  "success": true,
  "message": "Detail event berhasil diambil",
  "data": {
    "event": {
      "id": 1,
      "nama_event": "Konser Musik 2025",
      /* ... event fields ... */
    },
    "statistics": {
      "vendors": 5,
      "rundowns": 12,
      "tasks": 30
    }
  }
}
```

#### PUT /events/:id
Update event (Admin/Ketua Only).

**Request:**
```json
{
  "nama_event": "Updated Event Name",
  "status": "aktif"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Event berhasil diperbarui",
  "data": { /* event */ }
}
```

#### DELETE /events/:id
Hapus event (Admin Only).

**Response (204):** No content

---

### 🏢 VENDORS — Vendor per Event

#### GET /events/:id/vendors
List vendor untuk event tertentu.

**Query Params:**
- `page`, `per_page`
- `q` — Cari nama vendor
- `kategori` — Filter by kategori
- `status` — aktif, nonaktif
- `sort_by` — created_at, nama_vendor, status
- `order` — ASC, DESC

**Response (200):**
```json
{
  "success": true,
  "message": "Daftar vendor berhasil diambil",
  "data": {
    "vendors": [
      {
        "id": 1,
        "nama_vendor": "Catering XYZ",
        "kategori": "catering",
        "kontak_person": "Budi",
        "telepon": "08123456789",
        "email": "catering@xyz.com",
        "alamat": "Jl. Merdeka No. 1",
        "kontrak_url": "https://...",
        "event_id": 1,
        "status": "aktif",
        "catatan": "Sudah konfirmasi",
        "created_at": "2025-01-01T00:00:00.000Z"
      }
    ]
  },
  "meta": { /* pagination */ }
}
```

#### POST /events/:id/vendors
Tambah vendor untuk event (Admin/Ketua Only).

**Request:**
```json
{
  "nama_vendor": "Catering XYZ",
  "kategori": "catering",
  "kontak_person": "Budi",
  "telepon": "08123456789",
  "email": "catering@xyz.com",
  "alamat": "Jl. Merdeka No. 1",
  "status": "aktif"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Vendor berhasil ditambahkan",
  "data": { /* vendor */ }
}
```

#### GET /vendors/:id
Ambil detail vendor.

**Response (200):**
```json
{
  "success": true,
  "message": "Detail vendor berhasil diambil",
  "data": { /* vendor */ }
}
```

#### PUT /vendors/:id
Update vendor (Admin/Ketua Only).

**Response (200):**
```json
{
  "success": true,
  "message": "Vendor berhasil diperbarui",
  "data": { /* vendor */ }
}
```

#### DELETE /vendors/:id
Hapus vendor (Admin/Ketua Only).

**Response (204):** No content

---

### 📊 RUNDOWN — Timeline Event

#### GET /events/:id/rundowns
List rundown per event.

**Query Params:**
- `page`, `per_page`
- `q` — Cari judul sesi
- `status` — belum, proses, selesai
- `pic_id` — Filter by PIC
- `vendor_id` — Filter by vendor
- `sort_by` — urutan, created_at, waktu_mulai
- `order` — ASC, DESC

**Response (200):**
```json
{
  "success": true,
  "message": "Daftar rundown berhasil diambil",
  "data": {
    "rundowns": [
      {
        "id": 1,
        "event_id": 1,
        "urutan": 1,
        "waktu_mulai": "2025-06-01T08:00:00.000Z",
        "waktu_selesai": "2025-06-01T10:00:00.000Z",
        "judul_sesi": "Registrasi & Breakfast",
        "deskripsi": "Peserta registrasi dan makan pagi",
        "pic_id": 3,
        "pic": {
          "id": 3,
          "name": "PIC User"
        },
        "vendor_id": 1,
        "vendor": {
          "id": 1,
          "nama_vendor": "Catering XYZ"
        },
        "status": "belum",
        "created_at": "2025-01-01T00:00:00.000Z",
        "updated_at": "2025-01-01T00:00:00.000Z"
      }
    ]
  },
  "meta": { /* pagination */ }
}
```

#### POST /events/:id/rundowns
Tambah rundown (Admin/Ketua Only).

**Request:**
```json
{
  "urutan": 1,
  "waktu_mulai": "2025-06-01T08:00:00Z",
  "waktu_selesai": "2025-06-01T10:00:00Z",
  "judul_sesi": "Registrasi & Breakfast",
  "deskripsi": "Deskripsi sesi...",
  "pic_id": 3,
  "vendor_id": 1,
  "status": "belum"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Rundown berhasil ditambahkan",
  "data": { /* rundown */ }
}
```

#### PUT /rundowns/:id
Update rundown (Admin/Ketua Only).

**Response (200):**
```json
{
  "success": true,
  "message": "Rundown berhasil diperbarui",
  "data": { /* rundown */ }
}
```

#### DELETE /rundowns/:id
Hapus rundown (Admin/Ketua Only).

**Response (204):** No content

---

### ✅ TUGAS — Task Management

#### GET /events/:id/tugas
List tugas per event.

**Query Params:**
- `page`, `per_page`
- `q` — Cari judul tugas
- `status` — belum, proses, selesai, terkendala
- `prioritas` — rendah, sedang, tinggi, kritis
- `assignee_id` — Filter by assignee
- `divisi` — Filter by divisi
- `sort_by` — created_at, deadline, prioritas, status
- `order` — ASC, DESC

**Response (200):**
```json
{
  "success": true,
  "message": "Daftar tugas berhasil diambil",
  "data": {
    "tugas": [
      {
        "id": 1,
        "event_id": 1,
        "rundown_id": null,
        "judul": "Setup Sound System",
        "deskripsi": "Setup dan test semua speaker",
        "assignee_id": 3,
        "assignee": {
          "id": 3,
          "name": "Staf Sound",
          "email": "sound@gmail.com",
          "divisi": "Sound System"
        },
        "divisi": "Sound System",
        "prioritas": "tinggi",
        "status": "proses",
        "deadline": "2025-06-01T07:00:00.000Z",
        "lampiran_url": null,
        "catatan": "Progress 80%",
        "created_at": "2025-01-01T00:00:00.000Z",
        "updated_at": "2025-01-15T10:00:00.000Z"
      }
    ]
  },
  "meta": { /* pagination */ }
}
```

#### POST /events/:id/tugas
Buat tugas (Admin/Ketua Only).

**Request:**
```json
{
  "judul": "Setup Sound System",
  "deskripsi": "Setup dan test semua speaker",
  "assignee_id": 3,
  "divisi": "Sound System",
  "prioritas": "tinggi",
  "status": "belum",
  "deadline": "2025-06-01T07:00:00Z",
  "rundown_id": null,
  "lampiran_url": null
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Tugas berhasil dibuat",
  "data": { /* tugas */ }
}
```

#### GET /tugas/:id
Ambil detail tugas.

**Response (200):**
```json
{
  "success": true,
  "message": "Detail tugas berhasil diambil",
  "data": { /* tugas */ }
}
```

#### GET /tugas
List semua tugas (untuk staf, list tugas assigned).

**Query Params:** Same as `/events/:id/tugas`

**Response (200):** Same format

#### PUT /tugas/:id
Update tugas (Admin/Ketua Only).

**Response (200):**
```json
{
  "success": true,
  "message": "Tugas berhasil diperbarui",
  "data": { /* tugas */ }
}
```

#### PATCH /tugas/:id/status
Update status tugas (assignee atau admin/ketua).

**Request:**
```json
{
  "status": "selesai",
  "catatan": "Sudah selesai dan diverifikasi"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Status tugas berhasil diperbarui",
  "data": { /* tugas */ }
}
```

#### DELETE /tugas/:id
Hapus tugas (Admin/Ketua Only).

**Response (204):** No content

---

### 📝 LAPORAN — Reports per Event

#### GET /events/:id/laporan
List laporan per event.

**Query Params:**
- `page`, `per_page`
- `q` — Cari judul/konten
- `ketua_id` — Filter by pembuat
- `tanggal_from`, `tanggal_to` — Date range
- `sort_by` — created_at, tanggal, judul
- `order` — ASC, DESC

**Response (200):**
```json
{
  "success": true,
  "message": "Daftar laporan berhasil diambil",
  "data": {
    "laporan": [
      {
        "id": 1,
        "event_id": 1,
        "ketua_id": 2,
        "judul": "Laporan Event Hari 1",
        "konten": "Ringkasan acara hari pertama...",
        "file_url": "https://...",
        "tanggal": "2025-06-01",
        "ketua": {
          "id": 2,
          "name": "Ketua Event",
          "email": "ketua@gmail.com"
        },
        "created_at": "2025-06-01T20:00:00.000Z"
      }
    ]
  },
  "meta": { /* pagination */ }
}
```

#### POST /events/:id/laporan
Buat laporan (Admin/Ketua Only).

**Request:**
```json
{
  "judul": "Laporan Event Hari 1",
  "konten": "Ringkasan acara hari pertama...",
  "file_url": null,
  "tanggal": "2025-06-01"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Laporan berhasil dibuat",
  "data": { /* laporan */ }
}
```

---

### 📤 UPLOAD — File Upload

#### POST /upload
Upload single file (authenticated users).

**Form Data:**
- `file` (required) — File to upload (max 10MB)
- `folder` (optional) — Destination folder: avatar, kontrak, lampiran_tugas, laporan, chat_file, misc
- `resource_type` (optional) — Resource type for auto-folder mapping
- `resource_id` (optional) — Resource ID for folder structure

**Response (201):**
```json
{
  "success": true,
  "message": "File berhasil diupload",
  "data": {
    "file": {
      "bucket": "eventsync-files",
      "object_path": "uploads/lampiran-tugas/1234567890-document.pdf",
      "filename": "1234567890-document.pdf",
      "originalname": "document.pdf",
      "mimetype": "application/pdf",
      "size": 102400,
      "url": "https://storage.googleapis.com/eventsync-files/...",
      "gcs_uri": "gs://eventsync-files/...",
      "is_public": false
    }
  }
}
```

**Usage Example:**
```javascript
const formData = new FormData();
formData.append('file', fileInput.files[0]);
formData.append('folder', 'lampiran_tugas');
formData.append('resource_id', tugasId);

fetch('/api/v1/upload', {
  method: 'POST',
  headers: { 'Authorization': `Bearer ${token}` },
  body: formData
})
```

---

### 💬 REALTIME — Chat, Checklist, Notifikasi

#### POST /realtime/checklist
Buat checklist item (staf dalam event).

**Request:**
```json
{
  "event_id": 1,
  "item_name": "Setup speaker A",
  "description": "Setup dan test speaker A di stage",
  "assigned_to": 3,
  "status": "pending"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Checklist berhasil dibuat",
  "data": { /* checklist item */ }
}
```

#### GET /realtime/events/:eventId/checklist
List checklist per event (Admin/Ketua Only).

**Response (200):**
```json
{
  "success": true,
  "message": "Daftar checklist berhasil diambil",
  "data": {
    "checklist": [
      {
        "id": 1,
        "event_id": 1,
        "item_name": "Setup speaker A",
        "description": "Setup dan test speaker A di stage",
        "assigned_to": 3,
        "status": "pending",
        "created_at": "2025-01-01T00:00:00.000Z",
        "updated_at": "2025-01-01T00:00:00.000Z"
      }
    ]
  }
}
```

#### PATCH /realtime/checklist/:id/status
Update checklist item status.

**Request:**
```json
{
  "status": "completed"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Status checklist berhasil diperbarui",
  "data": { /* updated checklist */ }
}
```

#### POST /realtime/chat/messages
Kirim chat message (staf dalam event).

**Request:**
```json
{
  "event_id": 1,
  "divisi": "Sound System",
  "message": "Setup sudah 80% selesai",
  "file_url": null
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Chat message berhasil dikirim",
  "data": { /* message */ }
}
```

#### GET /realtime/events/:eventId/chat
List chat messages per event.

**Query Params:**
- `page`, `per_page`
- `divisi` — Filter by divisi

**Response (200):**
```json
{
  "success": true,
  "message": "Daftar chat berhasil diambil",
  "data": {
    "messages": [
      {
        "id": 1,
        "event_id": 1,
        "user_id": 3,
        "user_name": "Staf Sound",
        "divisi": "Sound System",
        "message": "Setup sudah 80% selesai",
        "file_url": null,
        "created_at": "2025-01-01T10:00:00.000Z"
      }
    ]
  },
  "meta": { /* pagination */ }
}
```

#### POST /realtime/notifikasi
Broadcast notifikasi (Admin/Ketua Only).

**Request:**
```json
{
  "recipient_id": 3,
  "title": "Update Status Tugas",
  "message": "Tugas 'Setup Sound System' selesai diverifikasi",
  "type": "info",
  "related_event_id": 1,
  "related_resource_type": "tugas",
  "related_resource_id": 5
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Notifikasi berhasil dikirim",
  "data": { /* notification */ }
}
```

#### GET /realtime/notifikasi/me
List notifikasi personal user.

**Response (200):**
```json
{
  "success": true,
  "message": "Daftar notifikasi berhasil diambil",
  "data": {
    "notifikasi": [
      {
        "id": 1,
        "recipient_id": 3,
        "title": "Update Status Tugas",
        "message": "Tugas 'Setup Sound System' selesai diverifikasi",
        "type": "info",
        "is_read": false,
        "related_event_id": 1,
        "created_at": "2025-01-01T10:00:00.000Z"
      }
    ]
  }
}
```

#### PATCH /realtime/notifikasi/:id/read
Mark notifikasi sebagai read.

**Response (200):**
```json
{
  "success": true,
  "message": "Notifikasi berhasil ditandai read",
  "data": { /* notification */ }
}
```

#### POST /realtime/rundown-changes
Log rundown change (Admin/Ketua Only).

**Request:**
```json
{
  "event_id": 1,
  "rundown_id": 1,
  "change_type": "update",
  "changed_fields": {
    "judul_sesi": "Registrasi (updated waktu)"
  },
  "old_values": { },
  "new_values": { }
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Perubahan rundown berhasil dicatat",
  "data": { /* change log */ }
}
```

#### GET /realtime/events/:eventId/rundown-changes
List rundown changes per event.

**Response (200):**
```json
{
  "success": true,
  "message": "Daftar perubahan rundown berhasil diambil",
  "data": {
    "changes": [
      {
        "id": 1,
        "event_id": 1,
        "rundown_id": 1,
        "changed_by_user_id": 2,
        "changed_by_user_name": "Ketua Event",
        "change_type": "update",
        "changed_fields": { /* fields */ },
        "old_values": { },
        "new_values": { },
        "created_at": "2025-01-01T10:00:00.000Z"
      }
    ]
  }
}
```

#### POST /realtime/logs
Create koordinasi log.

**Request:**
```json
{
  "event_id": 1,
  "log_type": "koordinasi",
  "title": "Koordinasi Divisi Sound",
  "description": "Meeting coordination untuk finalisasi sound setup",
  "participants": [1, 2, 3],
  "attachment_url": null
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Log koordinasi berhasil dicatat",
  "data": { /* log */ }
}
```

#### GET /realtime/events/:eventId/logs
List koordinasi logs per event (Admin/Ketua Only).

**Response (200):**
```json
{
  "success": true,
  "message": "Daftar log koordinasi berhasil diambil",
  "data": {
    "logs": [
      {
        "id": 1,
        "event_id": 1,
        "created_by_id": 2,
        "created_by_name": "Ketua Event",
        "log_type": "koordinasi",
        "title": "Koordinasi Divisi Sound",
        "description": "Meeting coordination...",
        "attachment_url": null,
        "created_at": "2025-01-01T10:00:00.000Z"
      }
    ]
  }
}
```

---

## Request/Response Format

### Standard Response Format

**Success (2xx):**
```json
{
  "success": true,
  "message": "Deskripsi berhasil",
  "data": { /* resource atau array */ },
  "meta": { /* optional: pagination, summary, etc */ }
}
```

**Error (4xx/5xx):**
```json
{
  "success": false,
  "message": "Deskripsi error",
  "statusCode": 400,
  "errors": [ /* optional: validation errors */ ]
}
```

### Pagination Format

```json
{
  "page": 1,
  "per_page": 10,
  "total": 50,
  "total_pages": 5
}
```

### Error Codes

| Status | Message |
|--------|---------|
| 400 | Bad Request — Invalid input |
| 401 | Unauthorized — Token invalid/expired |
| 403 | Forbidden — Insufficient permission |
| 404 | Not Found — Resource tidak ada |
| 500 | Server Error — Backend error |

---

## Panduan Implementasi

### 1. Setup Authentication

```javascript
// Store token di localStorage
localStorage.setItem('token', response.data.token);

// Add to every request
const headers = {
  'Authorization': `Bearer ${localStorage.getItem('token')}`,
  'Content-Type': 'application/json'
};

// Clear on logout
localStorage.removeItem('token');
```

### 2. Dashboard Admin

**Komponen:**
- User Statistics Card (total users, active/inactive)
- Event Overview (draft/aktif/selesai)
- Real-time Checklist Status
- Recent Activities Log
- System Health

**Data Fetch:**
```javascript
// Get statistics
GET /events?page=1&per_page=5
GET /users?page=1&per_page=5&role=staf
GET /realtime/notifikasi/me
```

### 3. Event Management (Ketua/Admin)

**Flow:**
1. List events → `GET /events`
2. Click event → `GET /events/:id`
3. View event details (vendors, rundowns, tasks, reports)
4. Create/Edit event → `POST /events` atau `PUT /events/:id`
5. Manage nested resources

**Key Pages:**
- Event List (with filters)
- Event Detail (tabs: vendors, rundowns, tasks, reports)
- Event Create/Edit Form
- Task Assignment Dialog

### 4. Task Management (Staf)

**Flow:**
1. View "My Tasks" → `GET /tugas?assignee_id=currentUserId`
2. Click task → `GET /tugas/:id`
3. View task details (description, deadline, attachments)
4. Update task status → `PATCH /tugas/:id/status`
5. Upload evidence/file → `POST /upload`

**Key Pages:**
- My Tasks List (filter by status)
- Task Detail
- Task Update Form
- File Upload Component

### 5. Real-time Features

**Chat:**
1. Join event → display chat input
2. Send message → `POST /realtime/chat/messages`
3. Poll for new messages → `GET /realtime/events/:eventId/chat` (every 5s) atau WebSocket

**Checklist:**
1. Display checklist items → `GET /realtime/events/:eventId/checklist`
2. Update item status → `PATCH /realtime/checklist/:id/status`

**Notifications:**
1. Fetch notifications → `GET /realtime/notifikasi/me`
2. Mark as read → `PATCH /realtime/notifikasi/:id/read`
3. Auto-poll every 30s atau WebSocket

### 6. Role-Based UI

```javascript
// Show/hide based on role
const canCreateEvent = ['admin', 'ketua'].includes(userRole);
const canAssignTask = ['admin', 'ketua'].includes(userRole);
const canSeeAllTasks = ['admin', 'ketua'].includes(userRole);

// API will also enforce on backend
```

---

## Authentication Flow

```
1. User registers/logs in
   → POST /auth/register or POST /auth/login
   
2. Server returns token
   → Store in localStorage
   
3. For protected routes
   → Add "Authorization: Bearer <token>" header
   
4. User logout
   → POST /auth/logout
   → Clear localStorage
   
5. Token expiry (24h)
   → Handle 401 response
   → Redirect to login
```

**Token Refresh Strategy:**
- Current: Token valid 24 hours
- On 401: Redirect to login
- Optional: Implement refresh token for seamless experience

---

## Best Practices

### 1. Error Handling
```javascript
try {
  const response = await fetch('/api/v1/events', { headers });
  if (!response.ok) {
    const error = await response.json();
    console.error(error.message);
    // Show user-friendly error message
  }
  const data = await response.json();
} catch (error) {
  // Network error
  console.error('Network error:', error);
}
```

### 2. Loading States
```javascript
const [loading, setLoading] = useState(false);
const [error, setError] = useState(null);

setLoading(true);
try {
  const data = await fetchEvents();
  setEvents(data);
} catch (err) {
  setError(err.message);
} finally {
  setLoading(false);
}
```

### 3. Pagination
```javascript
const [page, setPage] = useState(1);
const perPage = 10;

const fetchEvents = async () => {
  const response = await fetch(
    `/api/v1/events?page=${page}&per_page=${perPage}`
  );
  // ...
};
```

### 4. Search & Filter
```javascript
const [filters, setFilters] = useState({
  status: 'aktif',
  q: '',
  sort_by: 'created_at',
  order: 'DESC'
});

// Build query string
const params = new URLSearchParams(filters);
const url = `/api/v1/events?${params.toString()}`;
```

### 5. File Upload
```javascript
const uploadFile = async (file, folder) => {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('folder', folder);
  
  const response = await fetch('/api/v1/upload', {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${token}` },
    body: formData
  });
  
  return await response.json();
};
```

### 6. Form Validation
```javascript
// Client-side validation before submit
const validateEventForm = (data) => {
  if (!data.nama_event) return 'Nama event wajib diisi';
  if (!data.tanggal_mulai) return 'Tanggal mulai wajib diisi';
  if (data.tanggal_selesai < data.tanggal_mulai) {
    return 'Tanggal selesai harus setelah tanggal mulai';
  }
  return null;
};
```

### 7. State Management
- Use Redux/Vuex for complex state
- Or Context API + useReducer for simpler apps
- Store: auth (user, token), events, tasks, filters, ui (loading, modal, etc)

### 8. API Service Layer
```javascript
// services/api.js
const api = {
  auth: {
    login: (email, password) => fetch(...),
    logout: () => fetch(...),
    me: () => fetch(...)
  },
  events: {
    list: (filters) => fetch(...),
    get: (id) => fetch(...),
    create: (data) => fetch(...),
    update: (id, data) => fetch(...)
  }
};
```

---

## Summary — Feature Checklist

### Frontend Pages to Build
- [ ] Login & Register
- [ ] Admin Dashboard
- [ ] User Management (Admin)
- [ ] Event List & Detail
- [ ] Event Create/Edit Form
- [ ] Vendor Management (per event)
- [ ] Rundown Management (timeline view)
- [ ] Task Management (list, detail, status update)
- [ ] Report Management (view, create)
- [ ] My Tasks (for staf)
- [ ] Chat/Messages (per event)
- [ ] Checklist (per event)
- [ ] Notifications
- [ ] File Upload Component
- [ ] Profile Settings

### API Endpoints Summary
**Total Endpoints: 60+**
- Auth: 4
- Users: 5
- Events: 5
- Vendors: 5
- Rundowns: 4
- Tasks: 7
- Reports: 2
- Upload: 1
- Realtime: 14+

---

## Support & Contact

Untuk pertanyaan lebih lanjut, hubungi tim backend atau lihat README.md untuk setup instruksi lengkap.

**Last Updated:** May 24, 2026
