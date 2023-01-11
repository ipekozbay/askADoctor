const db = require('../models')
const Yorum = db.yorumlar


const yorumEkle = async (req, res) => {
  let info = {
    gonderenKullaniciAdi: req.body.gonderenKullaniciAdi,
    gonderenEmail: req.body.gonderenEmail,
    alici: req.body.alici,
    icerik: req.body.icerik,
  }

  const yorum = await Yorum.create(info)
  res.status(200).send(yorum)
  console.log(yorum)
}

const getYorumByAlici = async (req, res) => {
  let alici = req.params.alici

  let yorum = await Yorum.findAll({where: { alici : alici}})
  res.status(200).send(yorum)
  console.log(yorum)
}



module.exports = {
  yorumEkle,
  getYorumByAlici
}