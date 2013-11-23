angular.module('Courses.models')
.factory 'Schedule', (
  $rootScope,
  $location,
  $q,
  Course,
  CourseState,
  Section,
  Subsection,
) ->
  class Schedule
    constructor: () ->
      @courses = []
      @sectionsByDay = []
      @_semester = null
      @shouldUpdateURL = false

      for day in @getDays()
        @sectionsByDay[day] = []

    addCourse: (course) ->
      if _.findWhere(@courses, id: course.id)
        alert 'Warning: you have already selected this course'
        return
      if course.isValid() isnt true
        if not confirm 'Warning: this course is has no available sections.\nWould you like to add it anyway?'
          return

      @courses.push course
      if course.selectedSections.length > 0
      else if course.sections.length is 1
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
    initFromURL: () ->
      d = $q.defer()
      semester = $location.search()['semester']
      sections = $location.search()['sections']

      if not semester or not sections
        # No location parameter
        d.resolve false
        return d.promise

      callnums = sections.split ','

      promises =
        for callnum in callnums
          continue if not callnum
          Course.queryBySectionCall callnum, semester

      $q.all(promises).then (courses) =>
        # Temporarily disable URL updating
        @shouldUpdateURL = false

        @addCourses courses

        # Renable after inserting everything
        @shouldUpdateURL = true
        @updateURL()
        d.resolve true
      , (error) ->
        d.reject error

      d.promise

    updateURL: () ->
      selectedSections = @getSelectedSections()
      str = ''
      for selectedSection in selectedSections
        str += selectedSection.callNumber + ","
      if str and str.charAt(str.length - 1) == ','
        str = str.slice(0, -1)
      $location.search 'semester', @semester()
      $location.search 'sections', str

    # Will generate an array of all selected courses
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
    # This is the behavior when multiple sections need to be
    # selected from for a given course.
    exclusiveShowCourse: (course) ->
      sectionsByDay = []
      for day in @getDays()
        sectionsByDay[day] = course.getSectionsByDay day, false

      @sectionsByDay = sectionsByDay

    # Shows all courses that are selected for this schedule.
    # This is the default behavior.
    showAllSelectedCourses: () ->
      @sectionsByDay = @getSectionsByDay()
      @handleOverlaps @sectionsByDay

    # Will recalcuate the CSS for sections that are overlapping
    handleOverlaps: (sectionsByDay) ->
      subsectionsByDay = _.map sectionsByDay, (day) ->
        subsections = for section in day
          section.subsections

        _.flatten subsections

      seen = []
      for day in subsectionsByDay
        for subsection in day
          if seen.indexOf(subsection) isnt -1
            continue

          overlappingSubsections = _.filter day, (otherSubsection) ->
            # This will, of course, include section itself
            subsection.isOverlapping otherSubsection

          # There are overlapping sections (not just section itself)
          if overlappingSubsections and overlappingSubsections.length > 1
            Subsection.recalcCSS overlappingSubsections
            seen.push x for x in overlappingSubsections

    # Setter and getter for current semester.
    semester: (newSemester) ->
      if newSemester
        @_semester = newSemester
        @updateNewSemester()
      @_semester

    # Run to update section arrays after new courses are added.
    update: () ->
      courseStates = for course in @courses
        course.state()
      exVisIndex = courseStates.indexOf CourseState.EXCLUSIVE_VISIBLE
      if exVisIndex isnt -1
        @exclusiveShowCourse @courses[exVisIndex]
      else
        @showAllSelectedCourses()

      if @shouldUpdateURL
        @updateURL()

    # TODO: Implement. Clear schedule, etc.
    updateNewSemester: () ->
      return

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
