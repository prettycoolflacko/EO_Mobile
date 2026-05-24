const router = require('express').Router();
const tugasController = require('../../controllers/tugasController');
const db = require('../../models/sql');
const roleMiddleware = require('../../middleware/roleMiddleware');
const ownerMiddleware = require('../../middleware/ownerMiddleware');
const { validate } = require('../../middleware/validationMiddleware');
const { idParamSchema } = require('../../validators/commonSchemas');
const { tugasUpdateSchema, tugasStatusUpdateSchema } = require('../../validators/tugasSchemas');
const { tugasListQuerySchema } = require('../../validators/listQuerySchemas');

const getTugasAssigneeId = async (req) => {
	const tugas = await db.Tugas.findByPk(req.params.id);
	return tugas?.assignee_id;
};

router.get('/', validate(tugasListQuerySchema, 'query'), tugasController.listTugas);
router.get('/:id', validate(idParamSchema, 'params'), tugasController.getTugasById);
router.put('/:id', validate(idParamSchema, 'params'), validate(tugasUpdateSchema), tugasController.updateTugas);
router.patch('/:id/status', validate(idParamSchema, 'params'), ownerMiddleware(getTugasAssigneeId, 'id'), validate(tugasStatusUpdateSchema), tugasController.updateTugasStatus);
router.delete('/:id', roleMiddleware(['admin', 'ketua']), validate(idParamSchema, 'params'), tugasController.deleteTugas);

module.exports = router;