_ = require 'underscore'

default =
  facebook:
    clientID: '478856265465801'
    clientSecret: process.env.FACEBOOK_CLIENT_SECRET
    callbackURL: 'http://courses.adicu.com/'

development = {}

production = {}

module.exports = (env) ->
  if env == 'development'
    _.extend development, default
    development
  else if env == 'production'
    _.extend production, default
    production