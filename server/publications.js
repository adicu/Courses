Meteor.publish('courses', function(courseFulls) {
  if (!_.isArray(courseFulls)) {
    courseFulls = [courseFulls];
  }
  return [
    Courses.find({
      courseFull: {
        $in: courseFulls
      }
    }), Sections.find({
      courseFull: {
        $in: courseFulls
      }
    })
  ];
});

Meteor.publish('sections', function(sectionFulls) {
  if (!Co.isArray(sectionFulls)) {
    sectionFulls = [sectionFulls];
  }
  var courseFulls = _.map(sectionFulls, function(sectionFull) {
    Co.courseHelper.sectionFulltoCourseFull(sectionFull);
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
