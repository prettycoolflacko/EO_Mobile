# Endpoint Test Checklist - EventSync Backend

Gunakan file ini untuk mengecek endpoint satu per satu. Centang setelah endpoint berhasil diuji.

## Prasyarat

- [v] Database SQL sudah hidup
- [v] MongoDB sudah hidup
- [v] Backend sudah jalan di `http://localhost:8080`
- [v] Seeder demo data sudah dijalankan
- [v] Token login sudah disimpan

## 1. Auth

- [ ] `POST /api/v1/auth/register`
- [V] `POST /api/v1/auth/login`
- [V] `GET /api/v1/auth/me`
- [V] `POST /api/v1/auth/logout`

Catatan test:
- Pastikan login berhasil dan token diterima.
- Setelah logout, token lama tidak bisa dipakai lagi.

## 2. User Management

- [V] `GET /api/v1/users?page=1&per_page=10`
- [V] `GET /api/v1/users/:id`
- [V] `PUT /api/v1/users/:id`
- [V] `PATCH /api/v1/users/:id/role`
- [ ] `DELETE /api/v1/users/:id`

Checklist validasi:
- [V] `GET /users` hanya bisa diakses `admin` atau `ketua`
- [V] `PUT /users/:id` hanya bisa diakses `admin` atau `ketua`
- [V] `PATCH /users/:id/role` hanya bisa diakses `admin`
- [ ] `DELETE /users/:id` hanya bisa diakses `admin`

## 3. Event Management

- [V] `POST /api/v1/events`
- [V] `GET /api/v1/events?page=1&per_page=10`
- [V] `GET /api/v1/events/:id`
- [V] `PUT /api/v1/events/:id`
- [V] `DELETE /api/v1/events/:id`

Checklist validasi:
- [V] Query filter event diuji: `q`, `status`, `ketua_id`, `tanggal_mulai_from`, `tanggal_mulai_to`
- [V] Sorting event diuji: `sort_by`, `order`

## 4. Vendor Management

- [V] `POST /api/v1/events/:id/vendors`
- [V] `GET /api/v1/events/:id/vendors?page=1&per_page=10`
- [V] `GET /api/v1/vendors/:id`
- [V] `PUT /api/v1/vendors/:id`
- [V] `DELETE /api/v1/vendors/:id`

Checklist validasi:
- [ ] Filter vendor diuji: `q`, `status`, `kategori`
- [V] Sorting vendor diuji: `sort_by`, `order`
- [V] Update/delete vendor hanya bisa `admin` atau `ketua`

## 5. Rundown Management

- [ ] `POST /api/v1/events/:id/rundowns`
- [ ] `GET /api/v1/events/:id/rundowns?page=1&per_page=10`
- [ ] `PUT /api/v1/rundowns/:id`
- [ ] `DELETE /api/v1/rundowns/:id`

Checklist validasi:
- [ ] Filter rundown diuji: `q`, `status`, `pic_id`, `vendor_id`
- [ ] Sorting rundown diuji: `sort_by`, `order`
- [ ] Update/delete rundown hanya bisa `admin` atau `ketua`

## 6. Task Management (Tugas)

- [ ] `POST /api/v1/events/:id/tugas`
- [ ] `GET /api/v1/events/:id/tugas?page=1&per_page=10`
- [ ] `GET /api/v1/tugas/:id`
- [ ] `PUT /api/v1/tugas/:id`
- [ ] `PATCH /api/v1/tugas/:id/status`
- [ ] `DELETE /api/v1/tugas/:id`

Checklist validasi:
- [ ] Filter tugas diuji: `q`, `status`, `prioritas`, `assignee_id`, `divisi`
- [ ] Sorting tugas diuji: `sort_by`, `order`
- [ ] `PATCH /tugas/:id/status` hanya bisa user pemilik tugas atau admin
- [ ] `DELETE /tugas/:id` hanya bisa `admin` atau `ketua`

## 7. Laporan

- [ ] `POST /api/v1/events/:id/laporan`
- [ ] `GET /api/v1/events/:id/laporan?page=1&per_page=10`

Checklist validasi:
- [ ] Filter laporan diuji: `q`, `ketua_id`, `tanggal_from`, `tanggal_to`
- [ ] Sorting laporan diuji: `sort_by`, `order`
- [ ] Akses laporan hanya untuk `admin` dan `ketua`

## 8. File Upload

- [ ] `POST /api/v1/upload`

Checklist validasi:
- [ ] Upload file `.jpg`
- [ ] Upload file `.png`
- [ ] Upload file `.pdf`
- [ ] Upload file `.docx`
- [ ] Upload file `.xlsx`
- [ ] Coba upload file lebih dari 10 MB dan pastikan ditolak
- [ ] Coba upload tipe file tidak diizinkan dan pastikan ditolak
- [ ] Response upload mengembalikan `url` dan metadata file

## 9. Realtime / NoSQL

- [ ] `POST /api/v1/realtime/checklist`
- [ ] `GET /api/v1/realtime/events/:eventId/checklist`
- [ ] `PATCH /api/v1/realtime/checklist/:id/status`
- [ ] `POST /api/v1/realtime/chat/messages`
- [ ] `GET /api/v1/realtime/events/:eventId/chat`
- [ ] `POST /api/v1/realtime/notifikasi`
- [ ] `GET /api/v1/realtime/notifikasi/me`
- [ ] `PATCH /api/v1/realtime/notifikasi/:id/read`
- [ ] `POST /api/v1/realtime/rundown-changes`
- [ ] `GET /api/v1/realtime/events/:eventId/rundown-changes`
- [ ] `POST /api/v1/realtime/logs`
- [ ] `GET /api/v1/realtime/events/:eventId/logs`

Checklist validasi:
- [ ] Fitur realtime berjalan saat `MONGO_MODE=full`
- [ ] `GET /realtime/events/:eventId/checklist` hanya bisa `admin` atau `ketua`
- [ ] `GET /realtime/events/:eventId/rundown-changes` hanya bisa `admin` atau `ketua`
- [ ] Notifikasi milik user bisa dibaca dan ditandai read

## 10. Rekomendasi Urutan Test

1. Login dulu
2. Test `GET /auth/me`
3. Test `GET /events`
4. Test `GET /events/:id/tugas`
5. Test `PATCH /tugas/:id/status`
6. Test `POST /upload`
7. Test endpoint realtime NoSQL
8. Test create/update/delete untuk role `admin` dan `ketua`

## 11. Catatan Cepat

- Selalu kirim header `Authorization: Bearer <token>` untuk endpoint protected.
- Gunakan Postman atau `curl` untuk test manual.
- Simpan token berbeda untuk `admin`, `ketua`, dan `staf` supaya bisa cek role enforcement.
