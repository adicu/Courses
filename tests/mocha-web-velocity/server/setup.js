_ = Npm.require('underscore');
var registry = {};

importCollection = function(collectionName, docs) {
  _.each(docs, function(doc){
    global[collectionName].insert(doc);
  });
};

importAllCollections = function() {
  var database = {};
  _.each(registry, function(docs, collectionName){
    importCollection(collectionName, docs);
  });
};

var courses = JSON.parse(
  Assets.getText('example-db/courses.json')
);
registry.Courses = courses;

var sections = JSON.parse(
  Assets.getText('example-db/sections.json')
);
registry.Sections = sections;

// Use chai assert like normal assert.
assert = chai.assert;

stubMeteor = function() {
  var sinon = Meteor.require('sinon');

  Session = {
    get: sinon.stub(),
    set: sinon.stub()
  };
};

