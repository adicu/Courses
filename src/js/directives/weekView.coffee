angular.module('Courses.directives')
.directive 'weekView', () ->
    templateUrl: 'partials/directives/weekView.html'

    scope: true

    controller: ($scope, $element, $attrs, $transclude, otherInjectables) ->
      $scope.hours = Calendar.getHours()
      $scope.days = Calendar.getDays()
