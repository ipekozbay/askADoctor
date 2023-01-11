const db = require('../models')
const Hasta = db.hastalar


const hastaEkle = async (req, res) => {
  let info = {
    email: req.body.email,
    password: req.body.password,
    ad: req.body.ad,
    soyad: req.body.soyad,
    cinsiyet: req.body.cinsiyet,
    yas: req.body.yas,
    boy: req.body.boy,
    kilo: req.body.kilo,
    kanGrubu: req.body.kanGrubu,
    kronikHastalik: req.body.kronikHastalik,
  }

  const hasta = await Hasta.create(info)
  res.status(200).send(hasta)
  console.log(hasta)
}

const hastaProfilGuncelle = async (req, res) => {
  let email = req.params.email
  let info = {
    ad: req.body.ad,
    soyad: req.body.soyad,
    cinsiyet: req.body.cinsiyet,
    yas: req.body.yas,
    boy: req.body.boy,
    kilo: req.body.kilo,
    kanGrubu: req.body.kanGrubu,
    kronikHastalik: req.body.kronikHastalik,
  }

  let hasta = await Hasta.update(info, {where: { email : email}})
  res.status(200).send(hasta)
  console.log(hasta)
}

const hastaByEmail = async (req, res) => {
  let email = req.params.email

  let hasta = await Hasta.findOne({where: { email : email}})
  res.status(200).send(hasta)
  console.log(hasta)
}

module.exports = {
  hastaEkle,
  hastaByEmail,
  hastaProfilGuncelle
}