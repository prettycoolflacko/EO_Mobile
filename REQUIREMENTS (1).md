# REQUIREMENTS — EventSync: Sistem Koordinasi Panitia & Vendor Acara

> **Versi:** 1.1  
> **Terakhir diperbarui:** 2025  
> **Status:** Aktif

---

## 1. Ringkasan Proyek

### 1.1 Deskripsi

**EventSync** adalah platform koordinasi acara berbasis web dan mobile yang memungkinkan koordinasi tugas panitia, vendor, dan rundown acara secara *realtime*. Sistem ini dirancang untuk mengatasi miskomunikasi antar divisi panitia, khususnya pada saat pelaksanaan acara (hari-H).

### 1.2 Permasalahan yang Diselesaikan

- Miskomunikasi antar divisi panitia saat hari-H
- Kurangnya visibilitas status tugas secara realtime
- Koordinasi vendor yang tidak terstruktur
- Perubahan rundown mendadak yang tidak terdistribusi secara cepat
- Tidak adanya log koordinasi terpusat

### 1.3 Pengguna Utama

| Peran | Platform | Akses |
|---|---|---|
| Ketua Panitia | Web (Desktop) | Full access: alokasi tugas, manajemen vendor, laporan |
| Staf EO / Divisi | Mobile (Web responsive) | Checklist tugas, chat divisi, notifikasi |
| Admin Sistem | Web (Desktop) | Manajemen user, konfigurasi sistem |

---

## 2. Arsitektur Sistem

### 2.1 Deployment Target

```
Platform Cloud: Google Cloud Platform (GCP)
```

| Komponen | Pilihan Deployment | Keterangan |
|---|---|---|
| Frontend Web | App Engine / Cloud Run | Dipilih salah satu via gacha |
| Backend API Utama | App Engine / Cloud Run | Dipilih salah satu via gacha |
| Layanan Autentikasi | App Engine / Cloud Run | Dipilih salah satu via gacha |
| Database SQL | GCE (VM) atau Cloud SQL | Data terstruktur utama |
| Database NoSQL | GCE (VM dengan MongoDB/Firebase) | Data realtime & log |
| Cloud Storage | Google Cloud Storage | Dokumen, foto, lampiran |

### 2.2 Tiga Service Utama (Microservice / Modular)

```
SERVICE 1 — Frontend Web (WAJIB)
  └── Dashboard Ketua Panitia (React / Vue / Next.js)

SERVICE 2 — Authentication Service
  └── Register, Login, JWT, Role-based access (Admin / Ketua / Staf)

SERVICE 3 — Core API Service
  └── CRUD Event, Panitia, Vendor, Rundown, Tugas, Laporan
```

### 2.3 Tech Stack yang Dipilih

> ⚠️ **Catatan untuk AI Agent:** Tech stack di bawah ini adalah referensi. Ikuti stack yang telah disepakati tim. Jangan ganti tanpa instruksi eksplisit.

```
Frontend        : React.js (atau pilihan tim: Vue.js / Next.js)
Backend API     : Node.js + Express.js
ORM (SQL)       : Sequelize v6 (dengan sequelize-cli untuk migrations & seeders)
Database SQL    : MySQL / PostgreSQL
Database NoSQL  : MongoDB (Mongoose) / Firebase Firestore
Runtime         : Node.js 20+
Containerisasi  : Docker (untuk Cloud Run)
Storage         : Google Cloud Storage SDK
Auth            : JWT (JSON Web Token) + Bcrypt
```

---

## 3. Database Design

### 3.1 Database SQL — Data Terstruktur (via Sequelize)

> Minimal **5 tabel** wajib ada.  
> Semua tabel didefinisikan sebagai **Sequelize Model** di `src/models/sql/`.  
> Gunakan **Sequelize Migrations** (`npx sequelize-cli db:migrate`) untuk membuat tabel — jangan buat tabel manual via SQL kecuali untuk referensi.

#### Dependensi yang Diperlukan
```bash
npm install sequelize sequelize-cli mysql2   # Untuk MySQL
# atau
npm install sequelize sequelize-cli pg pg-hstore  # Untuk PostgreSQL
```

#### Inisialisasi Sequelize
```bash
npx sequelize-cli init
# Akan membuat folder: config/, models/, migrations/, seeders/
```

#### Konfigurasi `config/config.json`
```json
{
  "development": {
    "username": "DB_USER",
    "password": "DB_PASSWORD",
    "database": "eventsync_db",
    "host": "DB_HOST",
    "dialect": "mysql",
    "dialectOptions": { "charset": "utf8mb4" }
  },
  "production": {
    "use_env_variable": "DATABASE_URL",
    "dialect": "mysql"
  }
}
```

> ⚠️ Gunakan environment variable `DATABASE_URL` di production. Jangan hardcode kredensial.

---

#### Model 1: `User` → tabel `users`

```javascript
// src/models/sql/User.js
module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define('User', {
    id:            { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    name:          { type: DataTypes.STRING(100), allowNull: false },
    email:         { type: DataTypes.STRING(100), allowNull: false, unique: true },
    password_hash: { type: DataTypes.STRING(255), allowNull: false },
    role:          { type: DataTypes.ENUM('admin', 'ketua', 'staf'), allowNull: false },
    divisi:        { type: DataTypes.STRING(50) },
    phone:         { type: DataTypes.STRING(20) },
    avatar_url:    { type: DataTypes.STRING(255) },
    is_active:     { type: DataTypes.BOOLEAN, defaultValue: true },
  }, {
    tableName: 'users',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  });

  User.associate = (models) => {
    User.hasMany(models.Event, { foreignKey: 'ketua_id', as: 'events_dipimpin' });
    User.hasMany(models.Tugas, { foreignKey: 'assignee_id', as: 'tugas_diterima' });
    User.hasMany(models.Rundown, { foreignKey: 'pic_id', as: 'rundowns_pic' });
    User.hasMany(models.LaporanKetua, { foreignKey: 'ketua_id', as: 'laporan' });
  };

  return User;
};
```

---

#### Model 2: `Event` → tabel `events`

```javascript
// src/models/sql/Event.js
module.exports = (sequelize, DataTypes) => {
  const Event = sequelize.define('Event', {
    id:              { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    nama_event:      { type: DataTypes.STRING(150), allowNull: false },
    deskripsi:       { type: DataTypes.TEXT },
    lokasi:          { type: DataTypes.STRING(200) },
    tanggal_mulai:   { type: DataTypes.DATEONLY, allowNull: false },
    tanggal_selesai: { type: DataTypes.DATEONLY, allowNull: false },
    status:          { type: DataTypes.ENUM('draft','aktif','selesai','batal'), defaultValue: 'draft' },
    ketua_id:        { type: DataTypes.INTEGER, allowNull: false,
                       references: { model: 'users', key: 'id' } },
  }, {
    tableName: 'events',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  });

  Event.associate = (models) => {
    Event.belongsTo(models.User, { foreignKey: 'ketua_id', as: 'ketua' });
    Event.hasMany(models.Vendor, { foreignKey: 'event_id', as: 'vendors' });
    Event.hasMany(models.Rundown, { foreignKey: 'event_id', as: 'rundowns' });
    Event.hasMany(models.Tugas, { foreignKey: 'event_id', as: 'tugas' });
    Event.hasMany(models.LaporanKetua, { foreignKey: 'event_id', as: 'laporan' });
  };

  return Event;
};
```

---

#### Model 3: `Vendor` → tabel `vendors`

```javascript
// src/models/sql/Vendor.js
module.exports = (sequelize, DataTypes) => {
  const Vendor = sequelize.define('Vendor', {
    id:             { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    nama_vendor:    { type: DataTypes.STRING(100), allowNull: false },
    kategori:       { type: DataTypes.STRING(50) },
    kontak_person:  { type: DataTypes.STRING(100) },
    telepon:        { type: DataTypes.STRING(20) },
    email:          { type: DataTypes.STRING(100) },
    alamat:         { type: DataTypes.TEXT },
    kontrak_url:    { type: DataTypes.STRING(255) },
    event_id:       { type: DataTypes.INTEGER, allowNull: false,
                      references: { model: 'events', key: 'id' } },
    status:         { type: DataTypes.ENUM('aktif','selesai','batal'), defaultValue: 'aktif' },
    catatan:        { type: DataTypes.TEXT },
  }, {
    tableName: 'vendors',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false,
  });

  Vendor.associate = (models) => {
    Vendor.belongsTo(models.Event, { foreignKey: 'event_id', as: 'event' });
    Vendor.hasMany(models.Rundown, { foreignKey: 'vendor_id', as: 'rundowns' });
  };

  return Vendor;
};
```

---

#### Model 4: `Rundown` → tabel `rundowns`

```javascript
// src/models/sql/Rundown.js
module.exports = (sequelize, DataTypes) => {
  const Rundown = sequelize.define('Rundown', {
    id:             { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    event_id:       { type: DataTypes.INTEGER, allowNull: false,
                      references: { model: 'events', key: 'id' } },
    urutan:         { type: DataTypes.INTEGER, allowNull: false },
    waktu_mulai:    { type: DataTypes.TIME, allowNull: false },
    waktu_selesai:  { type: DataTypes.TIME },
    judul_sesi:     { type: DataTypes.STRING(150), allowNull: false },
    deskripsi:      { type: DataTypes.TEXT },
    pic_id:         { type: DataTypes.INTEGER,
                      references: { model: 'users', key: 'id' } },
    vendor_id:      { type: DataTypes.INTEGER,
                      references: { model: 'vendors', key: 'id' } },
    status:         { type: DataTypes.ENUM('belum','berjalan','selesai','ditunda'), defaultValue: 'belum' },
  }, {
    tableName: 'rundowns',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  });

  Rundown.associate = (models) => {
    Rundown.belongsTo(models.Event, { foreignKey: 'event_id', as: 'event' });
    Rundown.belongsTo(models.User, { foreignKey: 'pic_id', as: 'pic' });
    Rundown.belongsTo(models.Vendor, { foreignKey: 'vendor_id', as: 'vendor' });
    Rundown.hasMany(models.Tugas, { foreignKey: 'rundown_id', as: 'tugas' });
  };

  return Rundown;
};
```

---

#### Model 5: `Tugas` → tabel `tugas`

```javascript
// src/models/sql/Tugas.js
module.exports = (sequelize, DataTypes) => {
  const Tugas = sequelize.define('Tugas', {
    id:           { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    event_id:     { type: DataTypes.INTEGER, allowNull: false,
                    references: { model: 'events', key: 'id' } },
    rundown_id:   { type: DataTypes.INTEGER, allowNull: true,
                    references: { model: 'rundowns', key: 'id' } },
    judul:        { type: DataTypes.STRING(150), allowNull: false },
    deskripsi:    { type: DataTypes.TEXT },
    assignee_id:  { type: DataTypes.INTEGER, allowNull: false,
                    references: { model: 'users', key: 'id' } },
    divisi:       { type: DataTypes.STRING(50) },
    prioritas:    { type: DataTypes.ENUM('rendah','sedang','tinggi','kritis'), defaultValue: 'sedang' },
    status:       { type: DataTypes.ENUM('belum','proses','selesai','terkendala'), defaultValue: 'belum' },
    deadline:     { type: DataTypes.DATE },
    lampiran_url: { type: DataTypes.STRING(255) },
    catatan:      { type: DataTypes.TEXT },
  }, {
    tableName: 'tugas',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  });

  Tugas.associate = (models) => {
    Tugas.belongsTo(models.Event, { foreignKey: 'event_id', as: 'event' });
    Tugas.belongsTo(models.Rundown, { foreignKey: 'rundown_id', as: 'rundown' });
    Tugas.belongsTo(models.User, { foreignKey: 'assignee_id', as: 'assignee' });
  };

  return Tugas;
};
```

---

#### Model 6: `LaporanKetua` → tabel `laporan_ketua` *(opsional, direkomendasikan)*

```javascript
// src/models/sql/LaporanKetua.js
module.exports = (sequelize, DataTypes) => {
  const LaporanKetua = sequelize.define('LaporanKetua', {
    id:       { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    event_id: { type: DataTypes.INTEGER, references: { model: 'events', key: 'id' } },
    ketua_id: { type: DataTypes.INTEGER, references: { model: 'users', key: 'id' } },
    judul:    { type: DataTypes.STRING(150) },
    konten:   { type: DataTypes.TEXT },
    file_url: { type: DataTypes.STRING(255) },
    tanggal:  { type: DataTypes.DATEONLY },
  }, {
    tableName: 'laporan_ketua',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false,
  });

  LaporanKetua.associate = (models) => {
    LaporanKetua.belongsTo(models.Event, { foreignKey: 'event_id', as: 'event' });
    LaporanKetua.belongsTo(models.User, { foreignKey: 'ketua_id', as: 'ketua' });
  };

  return LaporanKetua;
};
```

---

#### `src/models/sql/index.js` — Entry Point Sequelize

```javascript
// src/models/sql/index.js
'use strict';
const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 3306,
    dialect: 'mysql',       // ganti ke 'postgres' jika pakai PostgreSQL
    logging: process.env.NODE_ENV === 'development' ? console.log : false,
  }
);

const db = {};
db.Sequelize = Sequelize;
db.sequelize = sequelize;

// Daftarkan semua model di sini
db.User         = require('./User')(sequelize, Sequelize.DataTypes);
db.Event        = require('./Event')(sequelize, Sequelize.DataTypes);
db.Vendor       = require('./Vendor')(sequelize, Sequelize.DataTypes);
db.Rundown      = require('./Rundown')(sequelize, Sequelize.DataTypes);
db.Tugas        = require('./Tugas')(sequelize, Sequelize.DataTypes);
db.LaporanKetua = require('./LaporanKetua')(sequelize, Sequelize.DataTypes);

// Jalankan associate
Object.keys(db).forEach(modelName => {
  if (db[modelName].associate) db[modelName].associate(db);
});

module.exports = db;
```

---

#### Perintah Sequelize CLI yang Sering Dipakai

```bash
# Buat migration baru
npx sequelize-cli migration:generate --name create-users-table

# Jalankan semua migration
npx sequelize-cli db:migrate

# Rollback migration terakhir
npx sequelize-cli db:migrate:undo

# Buat seeder
npx sequelize-cli seed:generate --name demo-users

# Jalankan seeder
npx sequelize-cli db:seed:all
```

---

### 3.2 Database NoSQL — Data Realtime (Mongoose)

> Koleksi/dokumen MongoDB via **Mongoose**.  
> Semua schema didefinisikan di `src/models/nosql/`.

#### Dependensi yang Diperlukan
```bash
npm install mongoose
```

#### Koleksi 1: `checklist_realtime`
```javascript
// src/models/nosql/ChecklistRealtime.js
const mongoose = require('mongoose');
const schema = new mongoose.Schema({
  tugas_id:   { type: Number, required: true },
  event_id:   { type: Number, required: true },
  user_id:    { type: Number, required: true },
  status:     { type: String, enum: ['belum','proses','selesai','terkendala'], default: 'belum' },
  catatan:    String,
  location:   { lat: Number, lng: Number },
}, { timestamps: { createdAt: false, updatedAt: 'updated_at' } });
module.exports = mongoose.model('ChecklistRealtime', schema, 'checklist_realtime');
```

#### Koleksi 2: `chat_divisi`
```json
{
  "_id": "ObjectId",
  "event_id": "string",
  "divisi": "string",
  "pesan": "string",
  "pengirim_id": "int",
  "pengirim_nama": "string",
  "tipe": "text | gambar | file",
  "file_url": "string | null",
  "timestamp": "ISODate"
}
```

#### Koleksi 3: `notifikasi`
```json
{
  "_id": "ObjectId",
  "user_id": "int",
  "event_id": "int",
  "judul": "string",
  "pesan": "string",
  "tipe": "tugas | rundown | vendor | sistem",
  "is_read": false,
  "created_at": "ISODate"
}
```

#### Koleksi 4: `perubahan_rundown`
```json
{
  "_id": "ObjectId",
  "rundown_id": "int",
  "event_id": "int",
  "field_berubah": "string",
  "nilai_lama": "string",
  "nilai_baru": "string",
  "diubah_oleh": "int",
  "alasan": "string",
  "timestamp": "ISODate"
}
```

#### Koleksi 5: `log_koordinasi`
```json
{
  "_id": "ObjectId",
  "event_id": "int",
  "user_id": "int",
  "aksi": "string",
  "entity": "tugas | vendor | rundown | event",
  "entity_id": "int",
  "detail": "object",
  "ip_address": "string",
  "timestamp": "ISODate"
}
```

---

## 4. REST API Endpoints

> **Base URL:** `https://<domain>/api/v1`  
> **Auth Header:** `Authorization: Bearer <JWT_TOKEN>`  
> **Content-Type:** `application/json`

### 4.1 Authentication (Service 2)

| # | Method | Endpoint | Deskripsi | Auth |
|---|---|---|---|---|
| 1 | `POST` | `/auth/register` | Daftar user baru | ❌ |
| 2 | `POST` | `/auth/login` | Login, mendapatkan JWT token | ❌ |
| 3 | `POST` | `/auth/logout` | Invalidate token | ✅ |
| 4 | `GET` | `/auth/me` | Profil user yang sedang login | ✅ |

### 4.2 User Management

| # | Method | Endpoint | Deskripsi | Role |
|---|---|---|---|---|
| 5 | `GET` | `/users` | Daftar semua user | Admin/Ketua |
| 6 | `GET` | `/users/:id` | Detail user | ✅ |
| 7 | `PUT` | `/users/:id` | Update data user | Admin/Ketua |
| 8 | `DELETE` | `/users/:id` | Hapus user | Admin |

### 4.3 Event Management

| # | Method | Endpoint | Deskripsi | Role |
|---|---|---|---|---|
| 9 | `POST` | `/events` | Buat event baru | Ketua/Admin |
| 10 | `GET` | `/events` | Daftar semua event | ✅ |
| 11 | `GET` | `/events/:id` | Detail event + statistik | ✅ |
| 12 | `PUT` | `/events/:id` | Update event | Ketua/Admin |
| 13 | `DELETE` | `/events/:id` | Hapus event | Admin |

### 4.4 Vendor Management

| # | Method | Endpoint | Deskripsi | Role |
|---|---|---|---|---|
| 14 | `POST` | `/events/:id/vendors` | Tambah vendor ke event | Ketua/Admin |
| 15 | `GET` | `/events/:id/vendors` | Daftar vendor per event | ✅ |
| 16 | `GET` | `/vendors/:id` | Detail vendor | ✅ |
| 17 | `PUT` | `/vendors/:id` | Update vendor | Ketua/Admin |
| 18 | `DELETE` | `/vendors/:id` | Hapus vendor | Ketua/Admin |

### 4.5 Rundown Management

| # | Method | Endpoint | Deskripsi | Role |
|---|---|---|---|---|
| 19 | `POST` | `/events/:id/rundowns` | Tambah sesi rundown | Ketua/Admin |
| 20 | `GET` | `/events/:id/rundowns` | Daftar rundown per event | ✅ |
| 21 | `PUT` | `/rundowns/:id` | Update sesi rundown | Ketua/Admin |
| 22 | `DELETE` | `/rundowns/:id` | Hapus sesi rundown | Ketua/Admin |

### 4.6 Task Management (Tugas)

| # | Method | Endpoint | Deskripsi | Role |
|---|---|---|---|---|
| 23 | `POST` | `/events/:id/tugas` | Buat & alokasikan tugas | Ketua/Admin |
| 24 | `GET` | `/events/:id/tugas` | Daftar tugas per event | ✅ |
| 25 | `GET` | `/tugas/:id` | Detail tugas | ✅ |
| 26 | `PUT` | `/tugas/:id` | Update tugas (termasuk status) | ✅ |
| 27 | `DELETE` | `/tugas/:id` | Hapus tugas | Ketua/Admin |
| 28 | `PATCH` | `/tugas/:id/status` | Update status tugas (checklist) | ✅ |

### 4.7 Laporan

| # | Method | Endpoint | Deskripsi | Role |
|---|---|---|---|---|
| 29 | `POST` | `/events/:id/laporan` | Buat laporan ketua | Ketua/Admin |
| 30 | `GET` | `/events/:id/laporan` | Semua laporan per event | Ketua/Admin |

### 4.8 Cloud Storage Upload

| # | Method | Endpoint | Deskripsi | Auth |
|---|---|---|---|---|
| 31 | `POST` | `/upload` | Upload file ke Cloud Storage, return URL | ✅ |

> **Total Endpoint:** 31 endpoint (melebihi minimum 15) ✅

---

## 5. Fitur Utama per Role

### 5.1 Web — Ketua Panitia (Dashboard)

- [ ] Dashboard ringkasan event (statistik tugas, progress rundown, vendor aktif)
- [ ] Manajemen event (CRUD)
- [ ] Alokasi tugas ke staf/divisi
- [ ] Manajemen rundown (drag-and-drop urutan)
- [ ] Manajemen vendor (kontrak, kontak, status)
- [ ] Monitoring checklist realtime (persentase penyelesaian per divisi)
- [ ] Notifikasi hari-H (trigger otomatis berdasarkan rundown)
- [ ] Laporan akhir acara (ekspor PDF/cetak)
- [ ] Upload dokumen ke Cloud Storage

### 5.2 Mobile-Responsive — Staf EO

- [ ] Melihat daftar tugas yang di-assign
- [ ] Checklist tugas (update status: selesai / terkendala)
- [ ] Melihat rundown hari-H
- [ ] Chat divisi (realtime via NoSQL)
- [ ] Notifikasi push (perubahan tugas, update rundown)
- [ ] Log koordinasi personal

---

## 6. Integrasi Cloud Storage

```
Provider  : Google Cloud Storage (GCS)
Bucket    : eventsync-files

Struktur folder:
  /avatars/{user_id}/
  /kontrak/{vendor_id}/
  /lampiran-tugas/{tugas_id}/
  /laporan/{event_id}/
  /chat-files/{chat_id}/
```

**Aturan:**
- File diupload via endpoint `POST /upload`
- Backend menyimpan URL publik/signed-URL ke kolom `*_url` di database
- Tipe file yang diizinkan: `.jpg`, `.jpeg`, `.png`, `.pdf`, `.docx`, `.xlsx`
- Maksimum ukuran file: **10 MB per file**

---

## 7. Response Format API

### 7.1 Success Response
```json
{
  "success": true,
  "message": "Berhasil",
  "data": { ... },
  "meta": {
    "page": 1,
    "per_page": 10,
    "total": 100
  }
}
```

### 7.2 Error Response
```json
{
  "success": false,
  "message": "Pesan error yang deskriptif",
  "errors": [
    { "field": "email", "message": "Email sudah digunakan" }
  ]
}
```

### 7.3 HTTP Status Code Convention

| Kode | Digunakan untuk |
|---|---|
| `200` | GET, PUT, PATCH sukses |
| `201` | POST sukses (resource dibuat) |
| `204` | DELETE sukses (no content) |
| `400` | Validasi gagal / bad request |
| `401` | Token tidak ada / expired |
| `403` | Tidak punya izin (role) |
| `404` | Resource tidak ditemukan |
| `500` | Internal server error |

---

## 8. Autentikasi & Otorisasi

```
Metode    : JWT (JSON Web Token)
Expiry    : 24 jam (access token)
Algorithm : HS256

Role Hierarchy:
  admin  → akses penuh semua endpoint
  ketua  → CRUD event, vendor, rundown, tugas; tidak bisa hapus user
  staf   → READ event/rundown, UPDATE status tugas milik sendiri, chat
```

**Middleware yang wajib dibuat:**
- `authMiddleware` — verifikasi JWT token
- `roleMiddleware(roles[])` — cek apakah role user ada di array yang diizinkan
- `ownerMiddleware` — cek apakah resource milik user yang request

---

## 9. Environment Variables

> ⚠️ **JANGAN commit file `.env` ke Git. Gunakan `.env.example` sebagai template.**

```env
# App
NODE_ENV=production
PORT=8080
APP_URL=https://your-domain.com

# Database SQL (dibaca oleh Sequelize)
DB_HOST=
DB_PORT=3306
DB_NAME=eventsync_db
DB_USER=
DB_PASSWORD=

# Database NoSQL
MONGO_URI=mongodb://...
# atau
FIREBASE_PROJECT_ID=

# JWT
JWT_SECRET=
JWT_EXPIRES_IN=24h

# Google Cloud Storage
GCS_BUCKET_NAME=eventsync-files
GCS_PROJECT_ID=
GOOGLE_APPLICATION_CREDENTIALS=./service-account.json

# CORS
ALLOWED_ORIGINS=https://frontend-domain.com
```

---

## 10. Struktur Folder Proyek (Referensi)

### Backend (Node.js/Express + Sequelize)
```
backend/
├── config/
│   └── config.json               ← Konfigurasi Sequelize (DB per environment)
├── migrations/                   ← File migration Sequelize (jangan edit manual)
├── seeders/                      ← Data awal / dummy data
├── src/
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── eventController.js
│   │   ├── vendorController.js
│   │   ├── rundownController.js
│   │   └── tugasController.js
│   ├── middleware/
│   │   ├── authMiddleware.js
│   │   └── roleMiddleware.js
│   ├── models/
│   │   ├── sql/                  ← Sequelize models (User, Event, Vendor, dst)
│   │   │   ├── index.js          ← Entry point, inisialisasi Sequelize
│   │   │   ├── User.js
│   │   │   ├── Event.js
│   │   │   ├── Vendor.js
│   │   │   ├── Rundown.js
│   │   │   ├── Tugas.js
│   │   │   └── LaporanKetua.js
│   │   └── nosql/                ← Mongoose schemas
│   │       ├── ChecklistRealtime.js
│   │       ├── ChatDivisi.js
│   │       ├── Notifikasi.js
│   │       ├── PerubahanRundown.js
│   │       └── LogKoordinasi.js
│   ├── routes/
│   │   └── v1/
│   ├── services/
│   │   ├── storageService.js     ← GCS integration
│   │   └── notifService.js
│   └── utils/
├── .sequelizerc                  ← Konfigurasi path untuk sequelize-cli
├── .env.example
├── Dockerfile
└── package.json
```

#### File `.sequelizerc`
```javascript
const path = require('path');
module.exports = {
  'config':          path.resolve('config', 'config.json'),
  'models-path':     path.resolve('src', 'models', 'sql'),
  'migrations-path': path.resolve('migrations'),
  'seeders-path':    path.resolve('seeders'),
};
```

### Frontend (React)
```
frontend/
├── src/
│   ├── pages/
│   │   ├── Dashboard/
│   │   ├── Events/
│   │   ├── Vendors/
│   │   ├── Rundown/
│   │   └── Tugas/
│   ├── components/
│   ├── hooks/
│   ├── services/          ← API call functions
│   ├── context/           ← Auth context
│   └── utils/
├── .env.example
├── Dockerfile
└── package.json
```

---

## 11. Checklist Pengerjaan

### Setup Infrastruktur
- [ ] Setup GCP Project
- [ ] Setup Cloud SQL / GCE untuk MySQL
- [ ] Setup GCE / MongoDB Atlas untuk NoSQL
- [ ] Setup Google Cloud Storage bucket
- [ ] Konfigurasi App Engine / Cloud Run untuk setiap service
- [ ] Setup CI/CD (opsional)

### Backend
- [ ] Inisialisasi project backend (`npm init`, install express, sequelize, dll)
- [ ] Inisialisasi Sequelize CLI (`npx sequelize-cli init`)
- [ ] Buat file `.sequelizerc` untuk konfigurasi path
- [ ] Definisikan semua Sequelize Model (6 model di `src/models/sql/`)
- [ ] Buat dan jalankan Migrations (`npx sequelize-cli db:migrate`)
- [ ] Buat Seeder untuk data dummy awal (`npx sequelize-cli db:seed:all`)
- [ ] Koneksi ke DB NoSQL (Mongoose)
- [ ] Koneksi ke Cloud Storage
- [ ] Implementasi autentikasi (register, login, JWT)
- [ ] CRUD Event (5 endpoint)
- [ ] CRUD Vendor (5 endpoint)
- [ ] CRUD Rundown (4 endpoint)
- [ ] CRUD Tugas + PATCH status (6 endpoint)
- [ ] Laporan (2 endpoint)
- [ ] Upload file (1 endpoint)
- [ ] Middleware auth + role

### Frontend
- [ ] Inisialisasi project frontend
- [ ] Halaman login / register
- [ ] Dashboard ringkasan (statistik)
- [ ] Halaman manajemen event
- [ ] Halaman manajemen vendor
- [ ] Halaman rundown (tampilan timeline)
- [ ] Halaman alokasi & monitoring tugas
- [ ] Tampilan mobile-responsive untuk staf
- [ ] Integrasi realtime (polling / WebSocket / Firebase listener)

### Dokumentasi
- [ ] Dokumentasi API (Postman Collection / Swagger)
- [ ] README setup & deployment
- [ ] Laporan proyek (sesuai template yang disediakan)

---

## 12. Catatan untuk AI Agent

> Bagian ini adalah instruksi konsistensi untuk AI coding agent di VS Code.

1. **Selalu baca file ini sebelum membuat kode baru.** Jangan membuat asumsi tentang nama tabel, endpoint, atau struktur folder.
2. **Nama tabel dan kolom** harus persis seperti yang tertulis di Bagian 3. Gunakan `snake_case`.
3. **ORM yang digunakan adalah Sequelize v6.** Semua operasi database SQL harus menggunakan Sequelize (model, query, association) — jangan gunakan raw SQL query kecuali benar-benar diperlukan dan dibungkus `sequelize.query()`.
4. **Migration wajib digunakan** untuk setiap perubahan skema database. Jangan jalankan `sequelize.sync({ force: true })` di production.
5. **Endpoint harus mengikuti** struktur di Bagian 4. Jangan menambah prefix berbeda tanpa konfirmasi.
6. **Response format** harus selalu mengikuti Bagian 7 (success/error wrapper).
7. **Environment variable** harus selalu dibaca dari `.env`, tidak pernah hardcode.
8. **Upload file** selalu melalui GCS via `storageService.js`, tidak melalui local disk.
9. **JWT validation** dilakukan di `authMiddleware.js`. Semua route yang butuh auth harus pakai middleware ini.
10. **Role check** dilakukan di `roleMiddleware.js`. Gunakan konstanta role: `'admin'`, `'ketua'`, `'staf'`.
11. **Perubahan arsitektur** (penambahan tabel, endpoint baru, perubahan schema) harus didokumentasikan di file ini terlebih dahulu, lalu buat migration baru — jangan edit migration yang sudah dijalankan.
12. **Jangan gabungkan logika SQL dan NoSQL** dalam satu controller. Pisahkan di service/model masing-masing.

---

*Dokumen ini adalah sumber kebenaran tunggal (single source of truth) untuk proyek EventSync.*
