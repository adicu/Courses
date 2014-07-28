var configureFacebook = function() {
  ServiceConfiguration.configurations.remove({
    service: "facebook"
  });

  ServiceConfiguration.configurations.insert({
    service: 'facebook',
    appId: Meteor.settings.facebook.appId,
    secret: Meteor.settings.facebook.secret
  });

  if (Meteor.settings.facebook.appId == '837193842965373') {
    console.log('Setting up development Facebook keys.');
    console.log('*NOTE*: only Facebook accounts added to the developer list ' +
      'will be able to login.');
  }
};

Meteor.startup(function() {
  // Import some NPM dependencies into
  // the global namespace on the server
  ejs = Meteor.require('elastic.js');

  if (process.env.NODE_ENV !== 'production') {
    // Relax browser policy in development
    BrowserPolicy.framing.allowAll();
  }

  configureFacebook();
});
