module.exports = (sequelize, DataTypes) => {
  const Doktor = sequelize.define('doktor',{
    email: {
      type: DataTypes.STRING,
      allowNull: false
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false
    },
    ad: {
      type: DataTypes.STRING,
      allowNull: false
    },
    soyad: {
      type: DataTypes.STRING,
      allowNull: false
    },
    cinsiyet: {
      type: DataTypes.STRING,
      allowNull: true
    },
    mezuniyetUni: {
      type: DataTypes.STRING,
      allowNull: true
    },
    bilimDali: {
      type: DataTypes.STRING,
      allowNull: true
    },
    uzmanlikAlani: {
      type: DataTypes.STRING,
      allowNull: true
    },
    hastaneTuru: {
      type: DataTypes.STRING,
      allowNull: true
    },
    hastaneAdi: {
      type: DataTypes.STRING,
      allowNull: true
    },


  })
  return Doktor
}