const router = require('express').Router();
const rundownController = require('../../controllers/rundownController');

router.put('/:id', rundownController.updateRundown);
router.delete('/:id', rundownController.deleteRundown);

module.exports = router;