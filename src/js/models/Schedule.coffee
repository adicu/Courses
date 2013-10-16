angular.module('Courses.models')
.factory 'Schedule', (
  $location,
  $q,
  Course,
  Section,
) ->
  class Schedule
    constructor: () ->
      @courses = []

    addCourse: (course) ->
      console.log course.id
      if _.findWhere(@courses, id: course.id)
        alert 'Warning: you have already selected this course'
        return
      if course.sections.length < 1
        alert 'Warning: this course has no scheduled sections'
        return

      @courses.push course

    addCourses: (courses) ->
      for course in courses
        @addCourse course

    fillFromURL: (term) ->
      if $location.search().hasOwnProperty('sections')
        callnum_string = ($location.search()).sections
      else
        # Support legacy routes using hash
        callnum_string = $location.hash()
      callnums = if callnum_string then callnum_string.split ',' else []

      promises =
        for callnum in callnums
          continue if not callnum
          CourseQuery.queryBySectionCall callnum, term

      $q.all(promises).then (sections) =>
        for section in sections
          @addCourse section.parentCourse

    # @param [number] days ints representing which days
    #   are wanted. Ex. [0, 1, 2] -> MTW
    getSectionsByDay: (days = @getDays()) ->
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

    getHours: ->
      return [8..23]

    getDays: ->
      return [0..4]
