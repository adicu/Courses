@Errors = new Meteor.Collection null

@handleError = (error) ->
  console.log 'Error: ' + error
  Errors.insert error: error
