module.exports = (sequelize, DataTypes) => {
  const Yorum = sequelize.define('yorum',{
    gonderenKullaniciAdi: {
      type: DataTypes.STRING,
      allowNull: false
    },
    gonderenEmail: {
      type: DataTypes.STRING,
      allowNull: false
    },
    alici: {
      type: DataTypes.STRING,
      allowNull: false
    },
    icerik: {
      type: DataTypes.STRING,
      allowNull: false
    },


  })
  return Yorum
}