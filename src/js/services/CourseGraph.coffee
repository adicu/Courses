angular.module('Courses.services')
  .factory 'CourseGraph', (

) ->
  class CourseGraph
    constructor: () ->
      @courses = []

    insertCourse: (course) ->
      if _.where(@courses, id: course.id) 
        alert 'Warning: you have already selected this course'
        return
      if course.sections.length < 1
        alert 'Warning: this course has no scheduled sections'
        return

      @courses.push course

    insertCourses: (courses) ->
      for course in courses
        @insertCourse course

    getTotalPoints: () ->
      points = 0
      for course in @courses
        if course.isSelected()
          points += course.points
      return points
