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

    isSelected: () ->
      @selected

    isOnDay: (day) ->
      for subsection in @subsections
        for meetDay in subsection.meetsOn
          if meetDay == day
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
