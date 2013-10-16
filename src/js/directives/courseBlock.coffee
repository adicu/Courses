angular.module('Courses.directives')
.directive 'courseBlock', () ->
    templateUrl: 'partials/directives/courseBlock.html'

    scope:
      schedule: '='

    link: (scope, elm, attrs) ->
