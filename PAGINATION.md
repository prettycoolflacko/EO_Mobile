# Pagination Guide

Dokumen ini menjelaskan cara memakai pagination di API EventSync.

## Ringkasan

Endpoint list di backend memakai parameter query berikut:

- `page` untuk nomor halaman
- `per_page` untuk jumlah data per halaman
- `sort_by` untuk kolom urut
- `order` untuk arah urut (`asc` atau `desc`)

Kalau tidak dikirim, default-nya:

- `page = 1`
- `per_page = 10`
- `order = desc`

Batas maksimal `per_page` adalah `100`.

## Endpoint Yang Mendukung Pagination

Endpoint berikut bisa memakai parameter pagination:

- `GET /api/v1/users`
- `GET /api/v1/events`
- `GET /api/v1/events/:id/vendors`
- `GET /api/v1/events/:id/rundowns`
- `GET /api/v1/events/:id/tugas`
- `GET /api/v1/events/:id/laporan`

Masing-masing endpoint juga bisa digabung dengan filter dan sorting sesuai resource-nya.

## Cara Kerja

Backend menghitung:

- `offset = (page - 1) * per_page`
- `limit = per_page`

Lalu data diambil dengan `offset` dan `limit` itu.

Response sukses akan menyertakan `meta` seperti ini:

```json
{
  "page": 1,
  "per_page": 10,
  "total": 25,
  "total_pages": 3
}
```

## Parameter

### `page`

Nomor halaman yang ingin diambil.

Contoh:

```text
?page=1
?page=2
```

### `per_page`

Jumlah data per halaman.

Contoh:

```text
?per_page=10
?per_page=25
```

Kalau lebih dari 100, backend akan tetap membatasi ke 100.

### `sort_by`

Kolom yang dipakai untuk sorting.

Setiap resource punya daftar kolom yang berbeda.

### `order`

Arah sorting.

- `asc`
- `desc`

Kalau nilai lain dikirim, backend akan pakai `desc`.

## Contoh Pemakaian

### Users

```bash
GET /api/v1/users?page=1&per_page=10&sort_by=name&order=asc
```

Filter yang tersedia:

- `q`
- `role`
- `divisi`
- `is_active`

### Events

```bash
GET /api/v1/events?page=2&per_page=5&status=aktif&sort_by=tanggal_mulai&order=desc
```

Filter yang tersedia:

- `q`
- `status`
- `ketua_id`
- `tanggal_mulai_from`
- `tanggal_mulai_to`

### Vendors per Event

```bash
GET /api/v1/events/1/vendors?page=1&per_page=10&sort_by=nama_vendor&order=asc
```

Filter yang tersedia:

- `q`
- `status`
- `kategori`

### Rundowns per Event

```bash
GET /api/v1/events/1/rundowns?page=1&per_page=10&sort_by=urutan&order=asc
```

Filter yang tersedia:

- `q`
- `status`
- `pic_id`
- `vendor_id`

### Tugas per Event

```bash
GET /api/v1/events/1/tugas?page=1&per_page=10&q=setup&sort_by=deadline&order=asc
```

Filter yang tersedia:

- `q`
- `status`
- `prioritas`
- `assignee_id`
- `divisi`

### Laporan per Event

```bash
GET /api/v1/events/1/laporan?page=1&per_page=10&sort_by=tanggal&order=desc
```

Filter yang tersedia:

- `q`
- `ketua_id`
- `tanggal_from`
- `tanggal_to`

## Format Response

Contoh response list:

```json
{
  "success": true,
  "message": "Daftar event berhasil diambil",
  "data": {
    "events": []
  },
  "meta": {
    "page": 1,
    "per_page": 10,
    "total": 0,
    "total_pages": 0
  }
}
```

## Tips Frontend

- Simpan `page` aktif di state supaya tombol next/prev konsisten.
- Pakai `meta.total_pages` untuk tahu kapan pagination selesai.
- Reset `page` ke 1 kalau filter atau search berubah.
- Untuk tabel besar, kirim `per_page` kecil dulu, misalnya 10 atau 20.

## Catatan Implementasi

Secara internal backend memakai helper di [src/utils/pagination.js](src/utils/pagination.js).

- `getPaginationParams()` untuk hitung `page`, `per_page`, `offset`, dan `limit`
- `buildPaginationMeta()` untuk isi `meta`
- `getSortParams()` untuk validasi `sort_by` dan `order`
