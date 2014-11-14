// Courses server-side search code

var ejs = ES.queryDSL;

// Adds additional options to elasticsearch queries
// for a given query string
var buildESQuery = function(query) {
  var match = '';
  var esQuery = ejs.BoolQuery().should(ejs.QueryStringQuery(query));

  if (match = query.match(/^([A-Z]{4})(\d{0,4})$/i)) {
    // Match course (ie COMS1004)
    var department = match[1];
    var courseNumber = match[2];
    var courseSearch = department + courseNumber + '*';

    esQuery.should(
      ejs.QueryStringQuery(courseSearch)
        .analyzeWildcard(true)
        .fields('Course')
        .boost(3.0)
    );
  } else if (match = query.match(/^([A-Z]{5})(\d{0,4})$/i)) {
    // Match course full (ie COMSW1004)
    var departmentWithDepartmentSuffix = match[1];
    var courseNumber = match[2];
    var courseSearch = departmentWithDepartmentSuffix + courseNumber + '*';

    esQuery.should(
      ejs.QueryStringQuery(courseSearch)
        .analyzeWildcard(true)
        .fields('CourseFull')
        .boost(3.0)
    );
  } else if (match = query.match(/^[A-Z]{4}$/i)) {
    // Match department (ie COMS)
    var department = match[0];
    esQuery.should(
      ejs.MatchQuery('DepartmentCode', department)
        .boost(1.5)
    );
  } else if (match = query.match(/^\d{5}$/i)) {
    // Match call number (ie 12345)
    var callNumber = match[0];
    esQuery.should(
      ejs.MatchQuery('CallNumber', callNumber)
        .boost(1.5)
    );
  } else if (query.length > 3) {
    esQuery.should(
      ejs.QueryStringQuery(query + '*')
        .analyzeWildcard(true)
        .fields('CourseTitle')
        .boost(2.0)
    );
  }

  return esQuery;
};

// Builds an elastic search filter
var buildESFilter = function(query, semester) {
  if (semester) {
    return ejs.TermFilter('Term', semester);
  }
};

var esSearch = Meteor.wrapAsync(ES.search, ES);

Meteor.methods({
  'Courses/search': function(query, semester) {
    var esBody = ejs.Request()
      .query(buildESQuery(query))
      .filter(buildESFilter(query, semester));

    var results = esSearch({
      index: 'data',
      type: 'courses',
      body: JSON.stringify(esBody)
    });
    if (!results.hits.hits) {
      handleError(new Error('Data not received for query'), query);
      return;
    }
    results = _.pluck(results.hits.hits, '_source');
    return results;
  }
});
