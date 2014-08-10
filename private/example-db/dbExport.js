// Use mongo courses --quiet --eval "load('./dbExport.js');exportCourses();" > courses.json
// mongo courses --quiet --eval "load('./dbExport.js');exportSections();" > sections.json
// etc.
//
// Need to strip ObjectID from resulting json file

var tryToPrintValidJSON = function (cursor) {
  // lol mongo
  print('[');
  var doc;
  while (cursor.hasNext()) {
    doc = cursor.next();

    // Make _id a string
    doc._id = doc._id.valueOf();

    printjsononeline(doc);
    if (cursor.hasNext()) {
      print(',');
    }
  }
  print(']');
};

var exportSections = function() {
  var courses = exportCourses(true);
  var courseFulls = [];
  courses.forEach(function(course) {
    courseFulls.push(course.courseFull);
  });

  var cursor = db.sections.find(
    {courseFull:
      {$in: courseFulls}
    }
  );
  tryToPrintValidJSON(cursor);
};

// @param returnCursor whether to return the courses
// cursor
var exportCourses = function(returnCursor) {
  var cursor = db.courses.find({courseFull: /^COMSW/});
  if (returnCursor) {
    return cursor;
  } else {
    tryToPrintValidJSON(cursor);
  }
};
