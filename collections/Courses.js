Courses = new Meteor.Collection('courses', {
  schema: new SimpleSchema({
    courseFull: {
      type: String,
      label: 'ex. COMSS3203',
      index: 1,
      unique: true
    },
    description: {
      type: String,
      optional: true
    },
    courseTitle: {
      type: String,
      label: 'ex. DISCRETE MATHEMATICS'
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
  })
});

// Adds additional options to a given elasticsearch request
// for a given query string
var buildRequest = function(query, ejsRequest) {
  var match = '';
  var ejsQuery = ejs.BoolQuery().should(ejs.QueryStringQuery(query));

  // Match full course (ie COMSW1004)
  if (match = query.match(/^([A-Z]{4})[A-Z]?(\d{1,4})/i)) {
    var department = match[1];
    var courseNumber = match[2];
    var courseSearch = department + courseNumber + '*';

    ejsQuery.should(ejs.FieldQuery('Course', courseSearch)).boost(3.0);
  } else if (match = query.match(/^[a-zA-Z]{4}/i)) {
    // Match department (ie COMS)
    var department = match[0];
    ejsQuery.should(ejs.FieldQuery('DepartmentCode', department)).boost(1.5);
  }
  ejsRequest.query(ejsQuery);
  return ejsRequest;
};

// Automatically performs the correct full text search for
// query, setting Session variable coursesSearchResults
Courses.search = function(query) {
  ejs.client = new ejs.jQueryClient(Co.constants.config.ES_API);
  var ejsRequest = ejs.Request().indices('data').types('courses');
  buildRequest(query, ejsRequest)
    .filter(
      ejs.TermFilter('Term', Session.get('currentSemester'))
    )
    .doSearch()
    .then(function(data) {
      if (!(data && data.hits && data.hits.hits)) {
        handleError(new Error('Data not received'));
        return;
      }
      var hits = data.hits.hits;
      hits = _.map(hits, function(hit) {
        return hit['_source'];
      });
      Session.set('coursesSearchResults', hits);
    }, function(error) {
      handleError(error);
    });
};

Courses.helpers({
  // @return [Sections] The sections associated with this course
  // for the current semester
  getSections: function(options) {
    var query = {
      courseFull: this.courseFull
    };
    if (Session && Session.get('currentSemester')) {
      query.term = Session.get('currentSemester');
    }
    return Sections.find(query, options);
  }
});
