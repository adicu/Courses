angular.module('Courses.directives')
.directive 'courseBlock', () ->
    templateUrl: 'partials/courseBlock.html'
    link: (scope, elm, attrs) ->
