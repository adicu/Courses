coffeeScript = require 'coffee-script'
express = require 'express'
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

port = process.env.NODE_PORT or 3000
app.listen port
console.log 'Express app started on port ' + port

exports = module.exports = app
