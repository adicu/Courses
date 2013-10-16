"use strict"

angular.module("Courses", [
  'Courses.controllers',
  'Courses.filters',
  'Courses.services',
  'Courses.directives',
  'Courses.constants',
  'ui.jq',
  ])
    .config ($routeProvider) ->
      $routeProvider.when "/schedule",
        templateUrl: "partials/schedule.html"
        controller: 'scheduleCtrl'
        reloadOnSearch: false
      $routeProvider.when "/directory",
        templateUrl: "partials/directory.html"
        controller: 'directoryCtrl'
      $routeProvider.otherwise redirectTo: "/schedule"

# Init internal modules here
# This is to make sure the modules are defined before
# the other code tries to add things to them
angular.module('Courses.controllers', [])
angular.module('Courses.directives', [])
angular.module('Courses.models', [])
angular.module('Courses.services', [])
