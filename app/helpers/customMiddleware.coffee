
exports.validationHandler = (req, res, next) ->
  errors = req.validationErrors()
  if (errors)
    res.send 'There have been validation errors: ' + util.inspect(errors), 400
    return
