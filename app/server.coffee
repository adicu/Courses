coffeeScript = require 'coffee-script'
customMiddleware = require './helpers/customMiddleware'
express = require 'express'
expressValidator = require 'express-validator'
fs = require 'fs'
mongoose = require 'mongoose'
passport = require 'passport'

env = process.env.NODE_ENV or 'development'
config = require('./config/config')(env)

db = mongoose.connect(config.mongo.uriPre + config.mongo.db)

# Models
require './models/SectionData'
require './models/CourseData'
require './models/Course'

require('./config/passport')(config)

app = express()

require('./config/routes')(config, app)

app.use express.compress()
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use expressValidator()
app.use customMiddleware.validationHandler

port = process.env.NODE_PORT or 3000
app.listen port
console.log 'Express app started on port ' + port

exports = module.exports = app
