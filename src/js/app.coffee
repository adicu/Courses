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
  'ezfb', # angularjs-ezfb, FB SDK wrapper
  '$strap.directives' # angular-strap
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
.config ($FBProvider) ->
  $FBProvider.setInitParams
    appId: '478856265465801'
    cookie: true
.run (UserAuth) ->
  UserAuth.fbInit()

# Init internal modules here
# This is to make sure the modules are defined before
# the other code tries to add things to them
angular.module('Courses.controllers', [])
angular.module('Courses.directives', [])
angular.module('Courses.models', [])
angular.module('Courses.services', [])
