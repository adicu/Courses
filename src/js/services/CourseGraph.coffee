angular.module('Courses.services')
  .factory 'CourseGraph', (

) ->
  class CourseGraph
    constructor: (courses) ->
      @insertCourses courses
      @courses = []

    insertCourse: (course) ->
      if @courses[course.id]
        alert 'Warning: you have already selected this course'
        return
      if course.sections.length < 1
        alert 'Warning: this course has no scheduled sections'
        return

      if course.sections.length > 1
        @showAllSections course
      else
        @sectionChosen course.sections[0]

    insertCourses: (courses) ->
      for course in courses
        @insertCourse course

    totalPoints: () ->
      points = 0
      for key,course of @courses
        if course
          points += course.points
      return points
