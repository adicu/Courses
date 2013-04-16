"use strict"

# Elasticjs library, AngularUI
angular.module("Courses", ["Courses.filters", "Courses.services",
      "Courses.directives", "elasticjs.service", 'ui'])
    .config ["$routeProvider", ($routeProvider) ->
      $routeProvider.when "/schedule",
        templateUrl: "partials/root.html"
        controller: rootCtrl
        reloadOnSearch: false
      $routeProvider.otherwise redirectTo: "/schedule"
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
