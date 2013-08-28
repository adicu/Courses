angular.module('Courses.directives')
.directive 'searchArea', () ->
    templateUrl: 'partials/directives/searchArea.html'

    scope: true

    link: (scope, iElement, iAttrs, controller) ->
      $(iElement).foundation()

    controller: ($scope, $element, $attrs, $transclude, otherInjectables) ->
      $scope.searchResults = []
      calendar = $scope.calendar

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
