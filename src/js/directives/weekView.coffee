angular.module('Courses.directives')
.directive 'weekView', () ->
    templateUrl: 'partials/weekView.html'

    scope:
      calendar: '=calendar'

    link: (scope, elm, attrs) ->

