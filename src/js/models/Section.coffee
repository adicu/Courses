angular.module('Courses.models')
.factory 'Section', (
  CourseHelper,
) ->
  class Section
    constructor: (@data, @parentCourse) ->
      @subsections = []
      @selected = false
      CourseHelper.santizeData @data

      @callNumber = @data.CallNumber
      @id = @parentCourse.id
      @IDFull = @parentCourse.IDFull
      @points = @parentCourse.points
      @title = @parentCourse.title
      @instructor = @data.Instructor1Name

      @addSubsections()

    addSubsections: () ->
      for meets, i in @data.MeetsOn
        subsection =
          building:  @data.Building[i]
          room:      @data.Room[i]
          points:    @parentCourse.points
          meetsOn:   CourseHelper.parseDays @data.MeetsOn[i]
          startTime: CourseHelper.parseTime @data.StartTime[i]
          endTime:   CourseHelper.parseTime @data.EndTime[i]
        subsection.css = CourseHelper.computeCSS subsection.startTime,
          subsection.endTime
        @subsections.push subsection

    getSubData: (key) ->
      return '' if @subsections.length < 1
      @subsections[0][key]

    printLocation: () ->
      "#{@getSubData('building')} #{@getSubData('room')}"

    isSelected: () ->
      @selected

    isOnDay: (day) ->
      for subsection in @subsections
        for meetDay in subsection.meetsOn
          if meetDay == day
            return true
      return false

    isOverlapping: (other) ->
      for ts in @subsections
        for os in other.subsections
          if not (ts.endTime < os.startTime or os.endTime < ts.startTime)
            for thisDay in ts.meetsOn
              if os.meetsOn.indexOf thisDay
                return true
      return false

    # Checks to see if this section is valid
    isValid: () ->
      validity =
        @IDFull? and
        @title? and
        @points? and
        @subsections? and
        @subsections.length > 0
      validity

    getParentCourse: () ->
      @parentCourse

    select: (state = true) ->
      @selected = state
      if @parentCourse
        @parentCourse.selectSection this, state
