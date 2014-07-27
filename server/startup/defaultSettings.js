var defaultSettings = {
  'elasticsearch': {
    'host': 'localhost:9200'
  }
};

Meteor.startup(function() {
  if (_.isEmpty(Meteor.settings)) {
    console.log('Setting default settings');
    Meteor.settings = defaultSettings;
  }
});
