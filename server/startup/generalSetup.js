Meteor.startup(function() {
  // Import some NPM dependencies into
  // the global namespace on the server
  ejs = Meteor.require('elastic.js');

  if (process.env.NODE_ENV !== 'production') {
    // Relax browser policy in development
    BrowserPolicy.framing.allowAll();
  }
});
