var defaultSettings = {
  elasticsearch: {
    host: 'localhost:9200'
  },
  facebook: {
    appId: '837193842965373',
    // NOTE: only test app secret. Must be added to developer list.
    secret: '753f5034c3b52c8d689223a6eb026dc9'
  }
};

Meteor.startup(function() {
  if (_.isEmpty(Meteor.settings)) {
    console.log('Setting default settings');
    Meteor.settings = defaultSettings;
  }
});
