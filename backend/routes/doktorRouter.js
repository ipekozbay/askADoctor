const doktorController = require('../controllers/doktorController.js')
const router = require('express').Router()

router.post('/doktorEkle', doktorController.doktorEkle)

router.get('/:email', doktorController.doktorByEmail)

router.get('/filter/:uzmanlikAlani', doktorController.doktorByUzmanlikAlani)

router.get('/', doktorController.getAllDoctors)

router.patch('/profilGuncelle/:email', doktorController.doktorProfilGuncelle)

module.exports = router