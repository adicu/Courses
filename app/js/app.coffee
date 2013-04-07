"use strict"

# Declare app level module which depends on filters, and services
angular.module("Courses", ["Courses.filters", "Courses.services", 
      "Courses.directives", "elasticjs.service"])
    .config ["$routeProvider", ($routeProvider) ->
      $routeProvider.when "/",
        templateUrl: "partials/root.html"
        controller: rootCtrl
      $routeProvider.otherwise redirectTo: "/"
]

# Array.filter prototype
`
if (!Array.prototype.filter) {
  Array.prototype.filter = function(fun /*, thisp*/) {
    var len = this.length >>> 0;
    if (typeof fun != "function")
    throw new TypeError();

    var res = [];
    var thisp = arguments[1];
    for (var i = 0; i < len; i++) {
      if (i in this) {
        var val = this[i]; // in case fun mutates this
        if (fun.call(thisp, val, i, this))
        res.push(val);
      }
    }
    return res;
  };
}
`