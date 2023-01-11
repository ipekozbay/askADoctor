const express = require('express')
const cors = require('cors')
const app = express();

var corOptions = {
  origin: 'http://localhost/8080 '
}

// middlewares
app.use(cors(corOptions))
app.use(express.json())
app.use(express.urlencoded({extended: true}))


// routers

const hastaRouter = require('./routes/hastaRouter.js')
app.use('/api/hastalar', hastaRouter)

const doktorRouter = require('./routes/doktorRouter.js')
app.use('/api/doktorlar', doktorRouter)

const yorumRouter = require('./routes/yorumRouter.js')
app.use('/api/yorumlar', yorumRouter)



//testing
app.get('/', (req, res)=> {
  res.json({message: 'hello from api'})
})

//port

const PORT = process.env.PORT || 8080 

app.listen(PORT, () =>{
  console.log('server is running on port', PORT)
})


