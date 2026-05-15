const router = require('express').Router();
const vendorController = require('../../controllers/vendorController');

router.get('/:id', vendorController.getVendorById);
router.put('/:id', vendorController.updateVendor);
router.delete('/:id', vendorController.deleteVendor);

module.exports = router;