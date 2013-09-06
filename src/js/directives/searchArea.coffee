angular.module('Courses.directives')
.directive 'searchArea', (
  $rootScope,
  $timeout,
  CourseHelper
) ->
  templateUrl: 'partials/directives/searchArea.html'

  scope: true

  controller: ($scope, $element, $attrs, DEPARTMENTS) ->
    $scope.searchResults = []
    $scope.DEPARTMENTS = DEPARTMENTS
    calendar = $scope.calendar

    $scope.getSearchbarPlaceholder = () ->
      if $scope.selectedDepartment
        'Type a course title to begin...'
      else
        '<- Select a department or enter call number'

    $scope.search = ->
      query = $scope.searchQuery
      if not query or query.length == 0
        $scope.clearResults()
        return
      calendar.search(query, $scope.selectedSemester)
        .then (data) ->
          if data == 'callnum'
            $scope.clearResults()
          else
            $scope.searchResults = data

    $scope.clearResults = ->
      $scope.searchResults = []
      $scope.searchQuery = ""

    $scope.courseSelect = (course) ->
      $scope.clearResults()
      course.fillData().then (status) ->
        return if not status
        console.log 'Added: ' + course
        calendar.addCourse course
