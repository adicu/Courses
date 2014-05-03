// From: https://github.com/zvictor/laika-extended-example
// Setup for fixtures
_ = require('underscore');
var registry = {};

addFixtures = function (collection, data){
  registry[collection] = data;
};

runFixtures = function(server, collection){
  return server.evalSync(function(collection, data) {

    _.each(data, function(doc){
      global[collection].insert( doc );
    });

    var fetch = global[collection].find().fetch();
    fetch = _.object(_.pluck(fetch, '_id'), fetch);

    emit('return', fetch);

  }, collection, registry[collection]);
};

runAllFixtures = function(server){
  var database = {};
  _.each(registry, function(data, collection){
    database[collection] = runFixtures(server, collection);
  });

  return database;
};

// Add fixtures by default
var courses = require('./fixtures/courses.json');
registry.Courses = courses;

var sections = require('./fixtures/sections.json');
registry.Sections = sections;
