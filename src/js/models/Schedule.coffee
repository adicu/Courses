angular.module('Courses.models')
  .factory 'Schedule', (

) ->
  class Schedule
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

    # @param [number] days ints representing which days
    #   are wanted. Ex. [0, 1, 2] -> MTW
    getSectionsByDay: (days) ->
      selectedCourses = _.filter @courses, (course) ->
        return course.isSelected()
      sectionsByDay = []
      for day in days
        sectionsByDay[day] = []
        sections = _.map selectedCourses, (course) ->
          course.getSectionsByDay(day)
        for section in sections
          if section
            sectionsByDay[day].push section
      sectionsByDay

    getTotalPoints: () ->
      points = 0
      for course in @courses
        if course.isSelected()
          points += course.points
      return points
