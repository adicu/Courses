angular.module('Courses.services')
.factory 'CourseQuery', (
  $http,
  $q,
  $rootScope,
  CONFIG,
  Course,
  Section,
) ->
  # Raw Querying class. Controllers shouldn't call directly.

  query: (query, term = $rootScope.selectedSemester) ->
    d = $q.defer()
    $http
      method: 'JSONP'
      url: CONFIG.DATA_API + 'search'
      params:
        jsonp: 'JSON_CALLBACK'
        api_token: CONFIG.API_TOKEN
        q: query
        term: term
    .success (data, status, headers, config) ->
      d.resolve data.data
    .error (data, status) ->
      d.reject new Error 'Query failed with status ' + status
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
      url: CONFIG.COURSES_API + 'sections/' + callNumber
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
