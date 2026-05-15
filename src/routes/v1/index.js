const router = require('express').Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const v1Routes = require('express').Router();

const authRoutes = require('./authRoutes');
const userRoutes = require('./userRoutes');
const eventRoutes = require('./eventRoutes');
const vendorRoutes = require('./vendorRoutes');
const rundownRoutes = require('./rundownRoutes');
const tugasRoutes = require('./tugasRoutes');
const laporanRoutes = require('./laporanRoutes');
const uploadRoutes = require('./uploadRoutes');

const vendorController = require('../../controllers/vendorController');
const rundownController = require('../../controllers/rundownController');
const tugasController = require('../../controllers/tugasController');
const laporanController = require('../../controllers/laporanController');

v1Routes.use('/auth', authRoutes);
v1Routes.use('/users', authMiddleware, userRoutes);
v1Routes.use('/events', authMiddleware, eventRoutes);

v1Routes.use('/vendors', authMiddleware, vendorRoutes);
v1Routes.use('/rundowns', authMiddleware, rundownRoutes);
v1Routes.use('/tugas', authMiddleware, tugasRoutes);
v1Routes.use('/laporan', authMiddleware, laporanRoutes);
v1Routes.use('/upload', authMiddleware, uploadRoutes);

v1Routes.post('/events/:id/vendors', authMiddleware, roleMiddleware(['admin', 'ketua']), vendorController.createVendor);
v1Routes.get('/events/:id/vendors', authMiddleware, vendorController.listVendorsByEvent);

v1Routes.post('/events/:id/rundowns', authMiddleware, roleMiddleware(['admin', 'ketua']), rundownController.createRundown);
v1Routes.get('/events/:id/rundowns', authMiddleware, rundownController.listRundownsByEvent);

v1Routes.post('/events/:id/tugas', authMiddleware, roleMiddleware(['admin', 'ketua']), tugasController.createTugas);
v1Routes.get('/events/:id/tugas', authMiddleware, tugasController.listTugasByEvent);

v1Routes.post('/events/:id/laporan', authMiddleware, roleMiddleware(['admin', 'ketua']), laporanController.createLaporan);
v1Routes.get('/events/:id/laporan', authMiddleware, roleMiddleware(['admin', 'ketua']), laporanController.listLaporanByEvent);

module.exports = v1Routes;