Courses = new Meteor.Collection('courses');

var schema = new SimpleSchema({
  courseFull: {
    type: String,
    label: 'ex. COMSS3203',
    index: 1,
    unique: true
  },
  course: {
    type: String,
    label: 'ex.COMS3203',
    index: 1
  },
  description: {
    type: String,
    optional: true
  },
  courseTitle: {
    type: String,
    label: 'ex. DISCRETE MATHEMATICS'
  },
  courseSubtitle: {
    type: String
  },
  departmentCode: {
    type: String,
    label: 'ex. COMS'
  },
  numFixedUnits: {
    type: Number,
    label: 'ex. 30'
  },
  createdAt: CollectionsShared.createdAt
});
Courses.attachSchema(schema);

// Indicates that the Courses search is still loading
Courses.SEARCH_LOADING_VAL = false;

// Automatically performs the correct full text search for
// query, setting Session variable coursesSearchResults
Courses.search = function(query, callback) {
  var currentSemester = Session.get('currentSemester');
  Session.set('coursesSearchResults', Courses.SEARCH_LOADING_VAL);
  Co.analytics.track('Courses/search', {
    query: query
  });


  // See server/CoursesSearch.js
  Meteor.call(
    'Courses/search',
    query,
    currentSemester,
    function(err, result) {
      if (err) {
        return handleError(err);
      }
      Session.set('coursesSearchResults', result);
      if(callback){
        callback();
      }
    }
  );
}

Courses.helpers({
  // @return Cursor The sections associated with this course
  // for the current semester
  getSections: function(options) {
    var query = {
      course: this.course
    };
    if (Session && Session.get('currentSemester')) {
      query.term = Session.get('currentSemester');
    }
    return Sections.find(query, options);
  }
});
