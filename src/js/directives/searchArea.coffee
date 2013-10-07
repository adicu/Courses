angular.module('Courses.directives')
.directive 'searchArea', (
  $rootScope,
  $timeout,
  Course,
  CourseHelper
) ->
  templateUrl: 'partials/directives/searchArea.html'

  scope: true

  controller: ($scope, $element, $attrs, $timeout) ->
    $scope.searchResults = []
    calendar = $scope.calendar
    previousSearch = null

    # Actual searching function
    runSearch = () ->
      query = $scope.searchQuery
      if not query or query.length == 0
        $scope.clearResults()
        return
      calendar.search(query, $scope.selectedSemester)
        .then (data) ->
          if data == 'callnum'
            $scope.clearResults()
          else
            console.log data
            $scope.searchResults = data

    # Will run searches after a delay
    $scope.search = () ->
      # Cancel the previous search if it hasn't started
      $timeout.cancel previousSearch if previousSearch
      previousSearch = $timeout runSearch, 400
      previousSearch.then (data) ->
        # Search has finshed, clear previousSearch
        previousSearch = null

    $scope.clearResults = () ->
      $scope.searchResults = []
      $scope.searchQuery = ""

    $scope.courseSelect = (course) ->
      $scope.clearResults()
      Course.fetchByCourseFull(course.CourseFull).then (course) ->
        console.log 'Added: ' + course
        calendar.addCourse course
