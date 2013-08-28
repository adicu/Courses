angular.module('Courses.directives')
.directive 'courseBlock', () ->
    templateUrl: 'partials/directives/courseBlock.html'
    link: (scope, elm, attrs) ->
