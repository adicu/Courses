angular.module('Courses.directives')
.directive 'appVersion', (version) ->
    (scope, elm, attrs) ->
      elm.text(version)
