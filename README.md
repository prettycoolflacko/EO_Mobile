# EventSync Backend API

Backend API untuk EventSync - Event Coordination Platform

## Setup Development

### 1. Install Dependencies
```bash
npm install
```

### 2. Database Setup
```bash
# Run SQL migrations
npx sequelize-cli db:migrate

# Seed demo data (optional)
npx sequelize-cli db:seed:all
```

### 3. Environment Configuration
Konfigurasi `.env` di root project dengan:
- Database credentials (MySQL)
- MongoDB connection string dan mode startup (`MONGO_MODE=full` sebagai default)
- JWT secret
- Google Cloud Storage config (optional)
- CORS allowed origins

### 4. Start Development Server
```bash
npm run dev
```

Server akan run di `http://localhost:8080`

## API Documentation

Untuk panduan pagination yang lebih fokus, lihat [PAGINATION.md](PAGINATION.md).

### Base URL
```text
http://localhost:8080/api/v1
```

### Roles
- `admin` - akses paling penuh
- `ketua` - operator utama event
- `staf` - akses terbatas sesuai penugasan

### Authentication
Semua endpoint selain `POST /auth/register` dan `POST /auth/login` memakai JWT.

```http
Authorization: Bearer <token>
Content-Type: application/json
```

Untuk upload file gunakan `multipart/form-data`.

### Response Format
Success:
```json
{
  "success": true,
  "message": "Sukses",
  "data": {},
  "meta": {
    "page": 1,
    "per_page": 10,
    "total": 100,
    "total_pages": 10
  }
}
```

Error:
```json
{
  "success": false,
  "message": "Pesan error",
  "errors": [
    { "field": "email", "message": "Email wajib diisi" }
  ]
}
```

### Endpoint Reference

#### Auth
| Method | Endpoint | Akses | Body |
|---|---|---|---|
| POST | `/auth/register` | Public | `name`, `email`, `password`, `role?=staf`, `divisi?`, `phone?`, `avatar_url?` |
| POST | `/auth/login` | Public | `email`, `password` |
| GET | `/auth/me` | Auth | - |
| POST | `/auth/logout` | Auth | - |

#### User
| Method | Endpoint | Akses | Body / Query |
|---|---|---|---|
| GET | `/users` | `admin`, `ketua` | `page?`, `per_page?`, `q?`, `role?`, `divisi?`, `is_active?`, `sort_by?`, `order?` |
| GET | `/users/:id` | Auth | - |
| PUT | `/users/:id` | `admin`, `ketua` | `name?`, `phone?`, `avatar_url?`, `divisi?`, `is_active?` |
| PATCH | `/users/:id/role` | `admin` | `role` |
| DELETE | `/users/:id` | `admin` | - |

#### Event
| Method | Endpoint | Akses | Body / Query |
|---|---|---|---|
| POST | `/events` | `admin`, `ketua` | `nama_event`, `deskripsi?`, `lokasi?`, `tanggal_mulai`, `tanggal_selesai`, `status?`, `ketua_id?` |
| GET | `/events` | Auth | `page?`, `per_page?`, `q?`, `status?`, `ketua_id?`, `tanggal_mulai_from?`, `tanggal_mulai_to?`, `sort_by?`, `order?` |
| GET | `/events/:id` | Auth | - |
| PUT | `/events/:id` | `admin`, `ketua` | `nama_event?`, `deskripsi?`, `lokasi?`, `tanggal_mulai?`, `tanggal_selesai?`, `status?` |
| DELETE | `/events/:id` | `admin` | - |

#### Vendor
| Method | Endpoint | Akses | Body / Query |
|---|---|---|---|
| POST | `/events/:id/vendors` | `admin`, `ketua` | `nama_vendor`, `kategori?`, `kontak_person?`, `telepon?`, `email?`, `alamat?`, `kontrak_url?`, `status?`, `catatan?` |
| GET | `/events/:id/vendors` | Auth | `page?`, `per_page?`, `q?`, `status?`, `kategori?`, `sort_by?`, `order?` |
| GET | `/vendors/:id` | Auth | - |
| PUT | `/vendors/:id` | `admin`, `ketua` | `nama_vendor?`, `kategori?`, `kontak_person?`, `telepon?`, `email?`, `alamat?`, `kontrak_url?`, `status?`, `catatan?` |
| DELETE | `/vendors/:id` | `admin`, `ketua` | - |

#### Rundown
| Method | Endpoint | Akses | Body / Query |
|---|---|---|---|
| POST | `/events/:id/rundowns` | `admin`, `ketua` | `urutan`, `waktu_mulai`, `waktu_selesai?`, `judul_sesi`, `deskripsi?`, `pic_id?`, `vendor_id?`, `status?` |
| GET | `/events/:id/rundowns` | Auth | `page?`, `per_page?`, `q?`, `status?`, `pic_id?`, `vendor_id?`, `sort_by?`, `order?` |
| PUT | `/rundowns/:id` | `admin`, `ketua` | `urutan?`, `waktu_mulai?`, `waktu_selesai?`, `judul_sesi?`, `deskripsi?`, `pic_id?`, `vendor_id?`, `status?` |
| DELETE | `/rundowns/:id` | `admin`, `ketua` | - |

#### Tugas
| Method | Endpoint | Akses | Body / Query |
|---|---|---|---|
| POST | `/events/:id/tugas` | `admin`, `ketua` | `judul`, `deskripsi?`, `assignee_id`, `divisi?`, `prioritas?`, `status?`, `deadline?`, `lampiran_url?`, `catatan?`, `rundown_id?` |
| GET | `/events/:id/tugas` | Auth | `page?`, `per_page?`, `q?`, `status?`, `prioritas?`, `assignee_id?`, `divisi?`, `sort_by?`, `order?` |
| GET | `/tugas/:id` | Auth | - |
| PUT | `/tugas/:id` | Auth | `judul?`, `deskripsi?`, `assignee_id?`, `divisi?`, `prioritas?`, `status?`, `deadline?`, `lampiran_url?`, `catatan?`, `rundown_id?` |
| PATCH | `/tugas/:id/status` | Owner tugas atau `admin` | `status`, `catatan?` |
| DELETE | `/tugas/:id` | `admin`, `ketua` | - |

#### Laporan
| Method | Endpoint | Akses | Body / Query |
|---|---|---|---|
| POST | `/events/:id/laporan` | `admin`, `ketua` | `judul`, `konten`, `file_url?`, `tanggal?` |
| GET | `/events/:id/laporan` | `admin`, `ketua` | `page?`, `per_page?`, `q?`, `ketua_id?`, `tanggal_from?`, `tanggal_to?`, `sort_by?`, `order?` |

#### Upload
| Method | Endpoint | Akses | Body |
|---|---|---|---|
| POST | `/upload` | Auth | multipart file pada field `file` |

#### Realtime / NoSQL
| Method | Endpoint | Akses |
|---|---|---|
| POST | `/realtime/checklist` | Auth |
| GET | `/realtime/events/:eventId/checklist` | `admin`, `ketua` |
| PATCH | `/realtime/checklist/:id/status` | Auth |
| POST | `/realtime/chat/messages` | Auth |
| GET | `/realtime/events/:eventId/chat` | Auth |
| POST | `/realtime/notifikasi` | `admin`, `ketua` |
| GET | `/realtime/notifikasi/me` | Auth |
| PATCH | `/realtime/notifikasi/:id/read` | Auth |
| POST | `/realtime/rundown-changes` | `admin`, `ketua` |
| GET | `/realtime/events/:eventId/rundown-changes` | `admin`, `ketua` |
| POST | `/realtime/logs` | Auth |
| GET | `/realtime/events/:eventId/logs` | `admin`, `ketua` |

### Contoh Request

Login:
```bash
curl -X POST http://localhost:8080/api/v1/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"admin@gmail.com\",\"password\":\"admin123\"}"
```

Ambil profile user:
```bash
curl http://localhost:8080/api/v1/auth/me ^
  -H "Authorization: Bearer <token>"
```

List event dengan filter dan pagination:
```bash
curl "http://localhost:8080/api/v1/events?page=1&per_page=10&status=aktif&sort_by=tanggal_mulai&order=asc" ^
  -H "Authorization: Bearer <token>"
```

Update status tugas milik sendiri:
```bash
curl -X PATCH http://localhost:8080/api/v1/tugas/1/status ^
  -H "Authorization: Bearer <token-staf>" ^
  -H "Content-Type: application/json" ^
  -d "{\"status\":\"selesai\",\"catatan\":\"Sudah diverifikasi\"}"
```

Upload file:
```bash
curl -X POST http://localhost:8080/api/v1/upload ^
  -H "Authorization: Bearer <token>" ^
  -F "file=@C:\path\to\file.pdf"
```

### Catatan Penting
- `POST /auth/register` saat ini hanya menerima role `staf`.
- Data demo memakai akun `admin@gmail.com`, `ketua@gmail.com`, `staf@gmail.com`, `catering@gmail.com`, dan `sound@gmail.com`.
- `GET /events/:id/vendors`, `GET /events/:id/rundowns`, `GET /events/:id/tugas`, dan `GET /events/:id/laporan` adalah endpoint nested yang dipakai frontend.
- `PATCH /tugas/:id/status` hanya boleh dipakai pemilik tugas atau `admin`.
- `DELETE /users/:id` bisa diakses `admin`, tetapi relasi data lain tetap harus lolos constraint database.
- Kalau role user berubah, token lama masih membawa role lama sampai login ulang.
- Untuk checklist test manual, lihat [TEST_ENDPOINT_CHECKLIST.md](TEST_ENDPOINT_CHECKLIST.md).

## Default Demo Users

| Email | Password | Role |
|-------|----------|------|
| admin@gmail.com | admin123 | admin |
| ketua@gmail.com | ketua123 | ketua |
| staf@gmail.com | staf123 | staf |

## Project Structure

```
src/
  ├── server.js              # Entry point
  ├── app.js                 # Express app setup
  ├── config/                # Configuration
  │   ├── sql.js            # Sequelize config
  │   └── mongo.js          # MongoDB config
  ├── models/
  │   ├── sql/              # Sequelize models
  │   └── nosql/            # Mongoose schemas
  ├── controllers/           # Business logic
  ├── routes/               # API routes
  ├── middleware/           # Authentication, authorization, error handling
  └── utils/                # Helper functions
migrations/                 # Database migrations
seeders/                    # Demo data seeders
```

## Tech Stack
- **Framework**: Express.js
- **SQL ORM**: Sequelize
- **NoSQL**: MongoDB/Mongoose
- **Authentication**: JWT
- **Password**: bcrypt
- **File Upload**: Multer (+ Google Cloud Storage)
- **Validation**: Custom (Joi/Zod recommended)
- **Middleware**: helmet, cors, morgan

## Notes
- Token yang sudah di-logout di-store di MongoDB TokenBlacklist
- Role-based access control (admin > ketua > staf)
- Semua response mengikuti standardized format
- Password di-hash dengan bcrypt, tidak pernah di-return dalam response
- Mode Mongo dikontrol oleh `MONGO_MODE`:
  - `full`: default, Mongo wajib tersedia untuk fitur realtime dan auth blacklist
  - `sql-only`: mode fallback opsional kalau ingin menonaktifkan fitur NoSQL sementara

## Troubleshooting
- **Koneksi database gagal**: Pastikan MySQL/MongoDB sudah running
- **JWT error**: Cek JWT_SECRET di .env
- **CORS error**: Tambah frontend URL ke ALLOWED_ORIGINS di .env
