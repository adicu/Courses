// This file is in js to be as optimized as possible.

var MongoClient = require('mongodb').MongoClient
var fs = require('fs');
var Q = require('q');
var args = process.argv.splice(2);
var SLICE_LENGTH = 50;

var insertDocuments = function(courses, doc, sliceIndex) {
  var d = Q.defer();

  var docSlice = doc.slice(
    sliceIndex * SLICE_LENGTH
  , (sliceIndex + 1) * SLICE_LENGTH
  );

  courses.insert(
    docSlice
  , {safe: true}
  , function (err, objects) {
      if (err) d.reject(err);
      console.log(docSlice.length + ' documents inserted.');
      d.resolve(true);
  }
  );

  return d.promise;
}

if (!args[0]) {
  console.log('File path to json needed.')
  return;
}

MongoClient.connect(
  'mongodb://127.0.0.1:27017/courses'
, {db: {native_parser: true}}
, function(err, db) {
    if (err) throw err;
    fs.readFile(args[0], 'utf8', function(err, data) {
      if (err) throw err;
      var courses = db.collection('courses');

      var doc = JSON.parse(data);
      console.log(doc.length + ' documents read in.');
      for (var i = 0; i < doc.length; i++) {
        if (doc[i].Term && doc[i].CallNumber) {
          // Generate IDs for the DB
          doc[i]._id = doc[i].Term + '-' + doc[i].CallNumber;
        }
      }

      var result = Q();
      for (var j = 0; j < (doc.length / SLICE_LENGTH + 1); j++) {
        result.then(insertDocuments(courses, doc, j));
      }
      result.then(function () {
        console.log('Insert completed.');
      }).done();
      return result;
  });
});