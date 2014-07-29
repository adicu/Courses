Errors = new Meteor.Collection(null);

handleError = function(error) {
  console.log(error);
  console.log('Error: ' + error);
  return Errors.insert({
    error: error
  });
};
