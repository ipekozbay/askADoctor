const db = require('../models')
const Doktor = db.doktorlar


const doktorEkle = async (req, res) => {
  let info = {
    email: req.body.email,
    password: req.body.password,
    ad: req.body.ad,
    soyad: req.body.soyad,
    cinsiyet: req.body.cinsiyet,
    mezuniyetUni: req.body.mezuniyetUni,
    bilimDali: req.body.bilimDali,
    uzmanlikAlani: req.body.uzmanlikAlani,
    hastaneTuru: req.body.hastaneTuru,
    hastaneAdi: req.body.hastaneAdi,
  }

  const doktor = await Doktor.create(info)
  res.status(200).send(doktor)
  console.log(doktor)
}

const doktorByEmail = async (req, res) => {
  let email = req.params.email

  let doktor = await Doktor.findOne({where: { email : email}})
  res.status(200).send(doktor)
  console.log(doktor)
}

const getAllDoctors = async (req, res) => {

  let doktor = await Doktor.findAll()
  res.status(200).send(doktor)
  console.log(doktor)
}

const doktorByUzmanlikAlani = async (req, res) => {
  let uzmanlikAlani = req.params.uzmanlikAlani

  let doktor = await Doktor.findAll({where: { uzmanlikAlani : uzmanlikAlani}})
  res.status(200).send(doktor)
  console.log(doktor)
}

const doktorProfilGuncelle = async (req, res) => {
  let email = req.params.email
  let info = {
    ad: req.body.ad,
    soyad: req.body.soyad,
    cinsiyet: req.body.cinsiyet,
    mezuniyetUni: req.body.mezuniyetUni,
    bilimDali: req.body.bilimDali,
    uzmanlikAlani: req.body.uzmanlikAlani,
    hastaneTuru: req.body.hastaneTuru,
    hastaneAdi: req.body.hastaneAdi,
  }

  let doktor = await Doktor.update(info, {where: { email : email}})
  res.status(200).send(doktor)
  console.log(doktor)
}


module.exports = {
  doktorEkle,
  doktorByEmail,
  doktorByUzmanlikAlani,
  doktorProfilGuncelle,
  getAllDoctors
}