angular.module('Courses.directives')
.directive 'courseBlock', () ->
  templateUrl: 'partials/directives/courseBlock.html'
  restrict: 'E'
  scope:
    schedule: '='