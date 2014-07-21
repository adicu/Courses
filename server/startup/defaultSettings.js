var defaultSettings = {
  'elasticsearch': {
    'host': 'localhost:9200'
  }
};

if (_.isEmpty(Meteor.settings)) {
  console.log('Setting default settings');
  Meteor.settings = defaultSettings;
}
