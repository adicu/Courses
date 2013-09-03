angular.module('Courses.directives')
.directive 'weekView', () ->
    templateUrl: 'partials/directives/weekView.html'

    scope: true

    controller: ($scope, $element, $attrs, $transclude) ->
      calendar = $scope.calendar

      $scope.sectionArray = calendar.getSectionArray()

      $scope.getDays = () ->
        calendar.getDays()
      $scope.getHours = () ->
        calendar.getHours()
