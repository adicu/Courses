"use strict"

# Declare app level module which depends on filters, and services
angular.module("Courses", ["Courses.filters", "Courses.services", "Courses.directives"])
    .config ["$routeProvider", ($routeProvider) ->
      $routeProvider.when "/",
        templateUrl: "partials/root.html"
        controller: rootCtrl
      $routeProvider.otherwise redirectTo: "/"
]