// Generated by CoffeeScript 1.3.3
"use strict";

angular.module("Courses.filters", []).filter('toTwelveHours', function() {
  return function(input) {
    if (input === 0) {
      return 'midnight';
    }
    if (input === 12) {
      return 'noon';
    }
    if (input < 12) {
      return input + 'am';
    }
    if (input > 12) {
      return (input - 12) + 'pm';
    }
  };
}).filter('readableSemester', function() {
  return function(input) {
    var out, semester, semesters;
    semesters = ['', 'Spring', 'Summer', 'Autumn'];
    semester = input[input.length - 1];
    return out = semesters[semester] + ' ' + input.slice(0, 4);
  };
});
