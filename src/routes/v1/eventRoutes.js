const router = require('express').Router();
const eventController = require('../../controllers/eventController');
const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

router.use(authMiddleware);

router.post('/', roleMiddleware(['admin', 'ketua']), eventController.createEvent);
router.get('/', eventController.listEvents);
router.get('/:id', eventController.getEventById);
router.put('/:id', roleMiddleware(['admin', 'ketua']), eventController.updateEvent);
router.delete('/:id', roleMiddleware(['admin']), eventController.deleteEvent);

module.exports = router;