Meteor.startup(function() {
  if (Courses.find().count() === 0 &&
    Sections.find().count() === 0) {

    // Only run on dev mode
    if (process.env.NODE_ENV === 'production'){
      return;
    }

    console.log('Importing only COMS courses into the database');
    console.log('**Adding other courses will not work!**');

    var importCollection = function(collectionName, docs) {
      _.each(docs, function(doc){
        global[collectionName].insert(doc);
      });
      var count = global[collectionName].find().count();
      console.log(count + ' ' + collectionName + ' inserted');
    };

    var courses = JSON.parse(
      Assets.getText('example-db/courses.json')
    );
    importCollection('Courses', courses);

    var sections = JSON.parse(
      Assets.getText('example-db/sections.json')
    );
    importCollection('Sections', sections);
  }
});
