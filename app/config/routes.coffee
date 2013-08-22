passport = require 'passport'

coursesCtr = require '../controllers/coursesCtr'

module.exports = (config, app) ->
  app.get '/auth/facebook',
    passport.authenticate 'facebook',
      successRedirect: '/'
      failureRedirect: '/#login'
      scope: 'publish_actions'
    (req, res) ->
      res.send 'Shouldn\'t see this.'

  app.get '/courses/:term/:courseID', coursesCtr.query

  app.get '/sections/:callNumber', coursesCtr.queryBySection
