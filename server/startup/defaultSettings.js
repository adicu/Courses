var defaultSettings = {
  elasticsearch: {
    host: 'localhost:9200'
  },
  facebook: {
    appId: '478856265465801',
    // NOTE: only test app secret. Must be added to developer list.
    secret: '753f5034c3b52c8d689223a6eb026dc9'
  },
  public: {
    // Just here for reference, loaded too late to work
    // See constants
    heapID: '252399778'
  }
};

Meteor.startup(function() {
  if (_.isEmpty(Meteor.settings)) {
    console.log('Setting default settings');
    Meteor.settings = defaultSettings;
  }
});
