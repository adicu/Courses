express = require 'express'
passport = require 'passport'
coffeeScript = require 'coffee-script'

env = process.env.NODE_ENV or 'development'
config = require('./config/config')(env)

require('./config/passport')(config)

app = express()

require('./config/routes')(config)

port = process.env.NODE_PORT or 3000
app.listen port
console.log 'Express app started on port ' + port

exports = module.exports = app