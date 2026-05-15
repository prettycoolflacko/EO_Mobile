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
- MongoDB connection string
- JWT secret
- Google Cloud Storage config (optional)
- CORS allowed origins

### 4. Start Development Server
```bash
npm run dev
```

Server akan run di `http://localhost:8080`

## API Documentation

### Base URL
```
http://localhost:8080/api/v1
```

### Authentication
Gunakan JWT token di header:
```
Authorization: Bearer <token>
```

### Auth Endpoints
- `POST /auth/register` - Register user baru
- `POST /auth/login` - Login dan dapatkan token
- `GET /auth/me` - Get profile user (protected)
- `POST /auth/logout` - Logout dan invalidate token

### User Management
- `GET /users` - List semua user (admin/ketua only)
- `GET /users/:id` - Get detail user
- `PUT /users/:id` - Update user profile
- `DELETE /users/:id` - Delete user (admin only)

### Event CRUD
- `POST /events` - Create event baru (admin/ketua)
- `GET /events` - List semua events
- `GET /events/:id` - Get event detail + statistics
- `PUT /events/:id` - Update event (admin/ketua)
- `DELETE /events/:id` - Delete event (admin)

### Vendor Management (per Event)
- `POST /events/:id/vendors` - Add vendor ke event
- `GET /events/:id/vendors` - List vendor per event
- `GET /vendors/:id` - Get vendor detail
- `PUT /vendors/:id` - Update vendor
- `DELETE /vendors/:id` - Delete vendor

### Rundown Management
- `POST /events/:id/rundowns` - Create rundown untuk event
- `GET /events/:id/rundowns` - List rundown per event (sorted by urutan)
- `PUT /rundowns/:id` - Update rundown
- `DELETE /rundowns/:id` - Delete rundown

### Task Management (Tugas)
- `POST /events/:id/tugas` - Create task untuk event
- `GET /events/:id/tugas` - List tasks per event
- `GET /tugas/:id` - Get task detail
- `PUT /tugas/:id` - Update task
- `PATCH /tugas/:id/status` - Update task status
- `DELETE /tugas/:id` - Delete task

### Report (Laporan)
- `POST /events/:id/laporan` - Create report untuk event
- `GET /events/:id/laporan` - List reports per event

### File Upload
- `POST /upload` - Upload file (protected)

## Default Demo Users

| Email | Password | Role |
|-------|----------|------|
| admin@eventsync.local | admin123 | admin |
| ketua@eventsync.local | ketua123 | ketua |
| staf@eventsync.local | staf123 | staf |

## Response Format

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... },
  "meta": { "page": 1, "per_page": 10, "total": 100 }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "errors": [
    { "field": "email", "message": "Email already exists" }
  ]
}
```

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

## Troubleshooting
- **Koneksi database gagal**: Pastikan MySQL/MongoDB sudah running
- **JWT error**: Cek JWT_SECRET di .env
- **CORS error**: Tambah frontend URL ke ALLOWED_ORIGINS di .env
