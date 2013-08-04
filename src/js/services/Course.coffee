angular.module('Courses.services')
.factory 'Course', ($q, Section, CoursesLoader) ->
  class Course

    constructor: (@id, @semester, @ejs_data=null) ->
      if @ejs_data
        @title = @ejs_data.coursetitle
        @description = @ejs_data.description
        @points = @ejs_data.numfixedunits / 10.0
