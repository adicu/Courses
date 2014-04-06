Errors = new Meteor.Collection null

handleError = (message) ->
  console.log 'Error ' + message
  Errors.insert message: message
