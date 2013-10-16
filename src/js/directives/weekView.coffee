angular.module('Courses.directives')
.directive 'weekView', () ->
    templateUrl: 'partials/directives/weekView.html'

    scope:
      schedule: '='

    controller: ($scope, $element, $attrs, $transclude) ->
      # $scope.sectionArray = calendar.getSectionArray()

      $scope.getDays = () ->
        $scope.schedule.getDays()
      $scope.getHours = () ->
        $scope.schedule.getHours()
