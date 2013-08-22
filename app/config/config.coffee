_ = require 'underscore'

defaultConfig =
  facebook:
    clientID: '478856265465801'
    clientSecret: process.env.FACEBOOK_CLIENT_SECRET
    callbackURL: 'http://courses.adicu.com/'

development =
  mongo:
    db: process.env.MONGO_DB or 'courses'
    uriPre: 'mongodb://localhost/'

production =
  mongo:
    db: process.env.MONGO_DB or 'courses'
    uriPre: 'mongodb://localhost/'

module.exports = (env) ->
  if env == 'development'
    _.extend development, defaultConfig
    development
  else if env == 'production'
    _.extend production, defaultConfig
    production