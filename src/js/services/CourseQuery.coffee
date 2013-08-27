angular.module('Courses.services')
.factory 'CourseQuery', (
  $http,
  $q,
  Course,
  Section,
  elasticSearch,
) ->
  @source = ''
  API_URL = 'db.adicu.com/api/' 

  query: (query, term) ->
    elasticSearch
      .query(
          ejs.BoolQuery()
          .must(ejs.WildcardQuery('term', '*' + semester  + '*'))
          .should(ejs.QueryStringQuery(query + '*')
            .fields(['coursetitle^3', 'course^4', 'description',
              'coursesubtitle', 'instructor^2']))
          .should(ejs.QueryStringQuery('*' + query + '*')
            .fields(['course', 'coursefull']))
          .minimumNumberShouldMatch(1)
      )
      .doSearch()
      .then (data) ->
        processedResults = CalendarUtil.processQueryResults data
        d.resolve processedResults

  queryBySectionCall: (callNumber, term, filters) ->
    d = $q.defer()
    $http
      method: 'JSONP'
      url: API_URL + 'sections/' + callNumber
      params:
        jsonp: 'JSON_CALLBACK'
        call_number: callNumber
        term: term
        withcourse: filters.withcourse or true
    .success (data, status, headers, config) =>
      course = new Course data
      course.chooseSection callNumber
      d.resolve course
    .error (data, status) ->
      d.reject new Error 'getCourseFromCall failed with status ' + status
    d.promise
