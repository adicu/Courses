// Use mongo --quiet --eval "load('./dbExport.js');exportCourses();" > courses.json
// mongo --quiet --eval "load('./dbExport.js');exportSections();" > sections.json
// etc.
//
// Need to strip ObjectID from resulting json file

var exportSections = function() {
  // Hack to read json files into shell
  var courses = eval(cat('courses.json'));
  var courseFulls = [];
  courses.forEach(function(course) {
    courseFulls.push(course.courseFull);
  });

  var sections = [];
  db.sections.find(
    {courseFull:
      {$in: courseFulls}
    }
  ).forEach(function(section) {
    sections.push(section);
  });

  printjson(sections);
};

var exportCourses = function() {
  var courses = [];
  db.courses.find({courseFull: /^COMSW/})
    .limit(10)
    .forEach(function(course) {
      courses.push(course);
    });

  printjson(courses);
};
