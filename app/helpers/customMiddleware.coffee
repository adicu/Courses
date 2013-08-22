
exports.validationHandler = (req, res, next) ->
  req.onValidationError () ->
    errors = @validationErrors()
    if (errors)
      res.jsonp 400, errors
      res.end()
      return
  next()
