const dbConfig = require('../config/dbConfig.js')
const {Sequelize, DataTypes} = require('sequelize')
const sequelize = new Sequelize(
  dbConfig.DB,
  dbConfig.USER,
  dbConfig.PASSWORD, {
    host: dbConfig.HOST,
    dialect: dbConfig.dialect,
    //operatorsAliases: false
  }

)

sequelize.authenticate()
.then(()=>{
  console.log('connected..')
})
.catch(err => {
  console.log('error' + err)
})

const db = {}

db.Sequelize = Sequelize
db.sequelize = sequelize

// tables
db.hastalar = require('./hastaModel.js')(sequelize, DataTypes)
db.doktorlar = require('./doktorModel.js')(sequelize, DataTypes)
db.yorumlar = require('./yorumModel.js')(sequelize, DataTypes)



db.sequelize.sync({force: false})
.then(()=>{
  console.log('re-sync done')
})

module.exports = db

