const yorumController = require('../controllers/yorumController.js')
const router = require('express').Router()

router.post('/yorumEkle', yorumController.yorumEkle)

router.get('/:alici', yorumController.getYorumByAlici)


module.exports = router