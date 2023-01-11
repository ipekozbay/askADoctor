module.exports = (sequelize, DataTypes) => {
  const Hasta = sequelize.define('hasta',{
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
    yas: {
      type: DataTypes.STRING,
      allowNull: true
    },
    boy: {
      type: DataTypes.STRING,
      allowNull: true
    },
    kilo: {
      type: DataTypes.STRING,
      allowNull: true
    },
    kanGrubu: {
      type: DataTypes.STRING,
      allowNull: true
    },
    kronikHastalik: {
      type: DataTypes.STRING,
      allowNull: true
    },


  })
  return Hasta
}