passport = require 'passport'

module.exports = (config) ->
  app.get '/auth/facebook/',
    passport.authenticate 'facebook',
      successRedirect: '/'
      failureRedirect: '/#login'
      scope: 'publish_actions'
      res.send 'Shouldn\'t see this.'
