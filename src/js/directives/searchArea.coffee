angular.module('Courses.directives')
.directive 'searchArea', (
  $rootScope,
  $timeout,
  Course,
  CourseHelper,
) ->
  templateUrl: 'partials/directives/searchArea.html'
  restrict: 'E'
  scope:
    onselect: '&'
    schedule: '='
    semesters: '='

  controller: ($scope, $element, $attrs, $timeout) ->
    $scope.searchResults = []
    previousSearch = null

    $scope.selectedSemester = $rootScope.selectedSemester =
      $scope.semesters[0]
    $scope.schedule.semester $scope.selectedSemester

    $scope.$watch 'selectedSemester', (newSemester) ->
      $scope.schedule.semester newSemester

    # Actual searching function
    runSearch = () ->
      query = $scope.searchQuery
      if not query or query.length == 0
        $scope.clearResults()
        return
      Course.search(query, $scope.selectedSemester)
        .then (data) ->
          if data == 'callnum'
            $scope.clearResults()
            # TODO: Success message
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

    $scope.courseSelect = (course) ->
      $scope.clearResults()
      $scope.onselect course

    $scope.clearResults = () ->
      $scope.searchResults = []
      $scope.searchQuery = ""

    $scope.changeSemester = (newSemester) ->
      $scope.selectedSemester = newSemester
