const router = require('express').Router();
const userController = require('../../controllers/userController');
const roleMiddleware = require('../../middleware/roleMiddleware');

router.get('/', roleMiddleware(['admin', 'ketua']), userController.listUsers);
router.get('/:id', userController.getUserById);
router.put('/:id', roleMiddleware(['admin', 'ketua']), userController.updateUser);
router.delete('/:id', roleMiddleware(['admin']), userController.deleteUser);

module.exports = router;