angular.module('Courses.models')
.factory 'Schedule', (
  $location,
  $q,
  Course,
  CourseState,
  Section,
) ->
  class Schedule
    constructor: () ->
      @courses = []
      @sectionsByDay = []

      for day in @getDays()
        @sectionsByDay[day] = []

    addCourse: (course) ->
      console.log course.id
      if _.findWhere(@courses, id: course.id)
        alert 'Warning: you have already selected this course'
        return
      if course.isValid() isnt true
        alert 'Warning: this course is invalid'
        return

      @courses.push course
      if course.sections.length is 1
        # Only one section, select by default
        course.sections[0].select()
      else
        # Show all the course's sections
        course.state CourseState.EXCLUSIVE_VISIBLE
      @update()

    addCourses: (courses) ->
      for course in courses
        @addCourse course

    removeCourse: (course) ->
      @courses = _.reject @courses, (c) ->
        c.IDFull is course.IDFull
      @update()

    # Fills the schedule from the URL parameters
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
          Course.queryBySectionCall callnum, term

      $q.all(promises).then (courses) =>
        for course in courses
          @addCourse course

    # Will generated an array of all selected courses
    # which have sections for given day(s)
    # @param [number] days ints representing which days
    #   are wanted. Ex. [0, 1, 2] -> MTW
    #   Call with no param to get all days
    getSectionsByDay: (days = @getDays()) ->
      selectedCourses = _.filter @courses, (course) ->
        return course.isSelected()
      sectionsByDay = []
      for day in days
        sectionsByDay[day] = []
        sections =
          for course in selectedCourses
            course.getSectionsByDay(day)
        sections = _.flatten sections
        for section in sections
          sectionsByDay[day].push section
      sectionsByDay

    getSelectedSections: () ->
      selectedCourses = _.filter @courses, (course) ->
        return course.isSelected()
      selectedSections = []
      for course in selectedCourses
        for selected in course.selectedSections
          selectedSections.push selected
      selectedSections

    # Exclusively show all the sections of a given course
    exclusiveShowCourse: (course) ->
      sectionsByDay = []
      for day in @getDays()
        sectionsByDay[day] = course.getSectionsByDay day, false

      @sectionsByDay = sectionsByDay

    # Run to update section arrays after new courses are added.
    update: () ->
      courseStates = for course in @courses
        course.state()
      exVisIndex = courseStates.indexOf CourseState.EXCLUSIVE_VISIBLE
      if exVisIndex isnt -1
        @exclusiveShowCourse @courses[exVisIndex]
      else
        @sectionsByDay = @getSectionsByDay()

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
