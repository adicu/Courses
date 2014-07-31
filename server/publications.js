// @param courseFulls either String or [String]
// some courseFulls to publish
Meteor.publish('courses', function(courseFulls) {
  if (!_.isArray(courseFulls)) {
    courseFulls = [courseFulls];
  }
  var courseIds = _.map(courseFulls, function(courseFull) {
    return Co.courseHelper.courseFullToCourse(courseFull);
  });
  return [
    Courses.find({
      courseFull: {
        $in: courseFulls
      }
    }), Sections.find({
      course: {
        $in: courseIds
      }
    })
  ];
});

// @param sectionFulls either String or [String]
// some sectionFulls to publish
Meteor.publish('sections', function(sectionFulls) {
  if (!Co.isArray(sectionFulls)) {
    sectionFulls = [sectionFulls];
  }
  var courseFulls = _.map(sectionFulls, function(sectionFull) {
    return Co.courseHelper.sectionFulltoCourseFull(sectionFull);
  });

  return [
    Sections.find({
      sectionFull: {
        $in: sectionFulls
      }
    }), Courses.find({
      courseFull: {
        $in: courseFulls
      }
    })
  ];
});

Meteor.publish('schedule', function(id) {
  check(id, String);
  return [
    Schedules.find(id)
  ];
});

Meteor.publish('mySchedules', function() {
  return [
    Schedules.find({
      owner: this.userId
    })
  ];
});
