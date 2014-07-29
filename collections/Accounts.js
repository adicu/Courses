// Not a custom collection, overriding Meteor behavior

Accounts.onCreateUser(function(options, user) {
  debugger;
  if (options.profile) {
    user.profile = options.profile;
  }
  return user;
})
