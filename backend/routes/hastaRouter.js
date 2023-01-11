const hastaController = require('../controllers/hastaController.js')
const router = require('express').Router()

router.post('/hastaEkle', hastaController.hastaEkle)

router.get('/:email', hastaController.hastaByEmail)

router.patch('/profilGuncelle/:email', hastaController.hastaProfilGuncelle)

module.exports = router