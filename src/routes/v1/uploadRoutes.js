const router = require('express').Router();
const uploadController = require('../../controllers/uploadController');

router.post('/', uploadController.uploadFile);

module.exports = router;