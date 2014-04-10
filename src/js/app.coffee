"use strict"

angular.module("Courses", [
  'ngCookies',
  'Courses.constants',
  'Courses.controllers',
  'Courses.directives',
  'Courses.filters',
  'Courses.models',
  'Courses.services',
  'ui.jq', # jQuery UI passthrough
  '$strap.directives', # angular-strap
  'elasticjs.service', # elastic.js
])
.config ($routeProvider) ->
  $routeProvider.when "/schedule",
    templateUrl: "partials/schedule.html"
    controller: 'scheduleCtrl'
    reloadOnSearch: false
  $routeProvider.otherwise redirectTo: "/schedule"

# Init internal modules here
# This is to make sure the modules are defined before
# the other code tries to add things to them
angular.module('Courses.controllers', [])
angular.module('Courses.directives', [])
angular.module('Courses.models', [])
angular.module('Courses.services', [])
