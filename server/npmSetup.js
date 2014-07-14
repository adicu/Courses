// This file will import some NPM dependencies into
// the global namespace on the server

Meteor.startup(function() {
  ejs = Meteor.require('elastic.js');
});
