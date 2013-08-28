angular.module('Courses.services')
.factory 'CourseQuery', (
  $http,
  $q,
  $rootScope
  Course,
  Section,
  elasticSearch,
) ->
  # Raw Querying class. Controllers shouldn't call directly.
  API_URL = 'db.adicu.com/api/'

  query: (query, term = $rootScope.selectedSemester) ->
    d = $q.defer()
    elasticSearch.executeCourseQuery(query, term)
    .then (data) ->
      console.log data
      # TODO: Process data
      d.resolve []
    d.promise

  # @return {Promise<Section>} Section for given callNumber.
  queryBySectionCall: (
    callNumber,
    term = $rootScope.selectedSemester,
    filters
  ) ->
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
      section = course.selectSectionByCall callNumber
      d.resolve section
    .error (data, status) ->
      d.reject new Error 'getCourseFromCall failed with status ' + status
    d.promise
