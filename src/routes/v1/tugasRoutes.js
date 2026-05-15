const router = require('express').Router();
const tugasController = require('../../controllers/tugasController');

router.get('/:id', tugasController.getTugasById);
router.put('/:id', tugasController.updateTugas);
router.patch('/:id/status', tugasController.updateTugasStatus);
router.delete('/:id', tugasController.deleteTugas);

module.exports = router;