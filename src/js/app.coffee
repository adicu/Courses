"use strict"

angular.module("Courses", [
  'Courses.controllers',
  'Courses.filters',
  'Courses.services',
  'Courses.directives',
  'Courses.constants',
  'elasticjs.service',
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
