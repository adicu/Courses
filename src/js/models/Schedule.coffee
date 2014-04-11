angular.module('Courses.models')
.factory 'Schedule', (
  $filter,
  $rootScope,
  $location,
  $q,
  Course,
  CourseState,
  Section,
  Subsection,
  Semesters,
  SemesterDates,
) ->
  ###
  Main model of Courses, representing a full schedule with multiple courses
  ###
  class Schedule
    constructor: () ->
      # Array of courses in the schedule
      @courses = []
      # For rendering purposes - 2D array
      # [day] -> [Sections] in the specified day
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
      @removeCourseFromURL(course)
      @courses = _.reject @courses, (c) ->
        c.IDFull is course.IDFull
      @update()

    removeCourseFromURL: (course) ->
      selectedSection = course.selectedSections[0]
      sectionNameParam = selectedSection.callNumber + ".name"
      sectionColorParam = selectedSection.callNumber + ".color"
      $location.search sectionNameParam, null
      $location.search sectionColorParam, null

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

        @applyCourseCustomizations(courses)

        @addCourses courses

        # Renable after inserting everything
        @shouldUpdateURL = true
        @updateURL()
        d.resolve true
      , (error) ->
        d.reject error

      d.promise


    ###
    Update the URL with colors and display names for each course

    writes to the url with the parameters [callNumber].name and
    [callNumber].color with the values of the display name and customized
    color respectively.

    @param courses: an array of courses in the current schedule
    ###
    applyCourseCustomizations: (courses) ->
      for course in courses
        selectedSection = course.selectedSections[0]
        sectionNameParam = selectedSection.callNumber + ".name"
        sectionColorParam = selectedSection.callNumber + ".color"
        if $location.search()[sectionNameParam]
          course.displayName = $location.search()[sectionNameParam]
        if $location.search()[sectionColorParam]
          course.color = $location.search()[sectionColorParam]

    updateURL: () ->
      selectedSections = @getSelectedSections()
      sectionsStr = ''
      liveCallNumbers = []
      for selectedSection in selectedSections
        sectionsStr += selectedSection.callNumber + ","
        liveCallNumbers.push selectedSection.callNumber
        sectionParent = selectedSection.getParentCourse()
        sectionNameParam = selectedSection.callNumber + ".name"
        if sectionParent.displayName != sectionParent.getDefaultDisplayName()
          $location.search sectionNameParam, sectionParent.displayName
        else
          # delete the default from the url
          $location.search sectionNameParam, null
        sectionColorParam = selectedSection.callNumber + ".color"
        $location.search sectionColorParam, sectionParent.color
      if sectionsStr and sectionsStr.charAt(sectionsStr.length - 1) == ','
        sectionsStr = sectionsStr.slice(0, -1)
      $location.search 'semester', @semester()
      $location.search 'sections', sectionsStr


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
          else
            subsection.reset()
    #Export to iCal
    getCalendar: () ->
      #format date
      rawStart = ""
      rawEnd = ""
      if(@_semester == Semesters[1])
        rawStart = SemesterDates["START_LAST"]
        rawEnd = SemesterDates["END_LAST"]
      else
        rawStart = SemesterDates["START_CURRENT"]
        rawEnd = SemesterDates["END_CURRENT"]
      startDate = rawStart.split("/")
      endDate = rawEnd.split("/")
      for i in [0..2]
        startDate[i] = parseInt(startDate[i])
        endDate[i] = parseInt(endDate[i])
      startDate[0] -= 1
      endDate[0] -= 1
      #create day of week array based on start date
      weekDayStart = new Date(startDate[2],startDate[0],startDate[1])
      monday = @getWeekDay(weekDayStart,1)
      tuesday = @getWeekDay(weekDayStart,2)
      wednesday = @getWeekDay(weekDayStart,3)
      thursday = @getWeekDay(weekDayStart,4)
      friday = @getWeekDay(weekDayStart,5)
      weekDay = [[monday.getMonth(),monday.getDate()],
      [tuesday.getMonth(),tuesday.getDate()],
      [wednesday.getMonth(),wednesday.getDate()],
      [thursday.getMonth(),thursday.getDate()],
      [friday.getMonth(),friday.getDate()]]
      #create calendar and add events
      calendar = new ICS "adicu.com//Courses"
      for scheduleEvent in @getSelectedSections()
        for subsectionEvent in scheduleEvent.subsections
          startTime = subsectionEvent.startTime.toString().split('.')
          endTime = subsectionEvent.endTime.toString().split('.')
          calendar.addEvent({
            DTSTART: new Date(startDate[2],
              weekDay[subsectionEvent.meetsOn[0]][0],
              weekDay[subsectionEvent.meetsOn[0]][1],
              parseInt(startTime[0]),
              Math.round(parseFloat("0."+startTime[1])*60),0),
            DTEND: new Date(endDate[2],
              weekDay[subsectionEvent.meetsOn[0]][0],
              weekDay[subsectionEvent.meetsOn[0]][1],
              parseInt(endTime[0]),
              Math.round(parseFloat("0."+endTime[1])*60),0),
            SUMMARY: $filter('titleCase')(scheduleEvent.title),
            LOCATION: subsectionEvent.building+" "+subsectionEvent.room,
            RRULE: "FREQ=WEEKLY;UNTIL="+ICSFormatDate(new Date(endDate[2],endDate[0],endDate[1],11,59,59))
          })

      calendar.download "Courses-schedule-" + @_semester

    #Helper functions for exporting to iCal
    getTomorrow: (currentDay,increment) ->
      new Date(currentDay.getFullYear(), currentDay.getMonth(), currentDay.getDate()+increment)

    getWeekDay: (currentDay,day) ->
      if(currentDay.getDay() != day)
        for i in [0..5]
          currentDay = @getTomorrow(currentDay,1)
          if currentDay.getDay() == day
            return currentDay
            break
      else
        return currentDay

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
