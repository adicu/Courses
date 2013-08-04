passport = require 'passport'
FacebookStrategy = require('passport-facebook').Strategy

module.exports = (config) ->
  passport.use new FacebookStrategy
    clientID: config.facebook.clientID
    clientSecret: config.facebook.clientSecret
    callbackURL: config.facebook.callbackURL
    (accessToken, refreshToken, profile, done) ->
      # TODO: Implement
