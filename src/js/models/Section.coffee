angular.module('Courses.models')
.factory 'Section', (
  CourseHelper,
  Subsection,
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
        subsection = new Subsection
          building:  @data.Building[i]
          room:      @data.Room[i]
          points:    @parentCourse.points
          meetsOn:   CourseHelper.parseDays @data.MeetsOn[i]
          startTime: CourseHelper.parseTime @data.StartTime[i]
          endTime:   CourseHelper.parseTime @data.EndTime[i]

        @subsections.push subsection

    getSubData: (key) ->
      return '' if @subsections.length < 1
      @subsections[0][key]

    printLocation: () ->
      "#{@getSubData('building')} #{@getSubData('room')}"

    isSelected: () ->
      @selected

    isOnDay: (day) ->
      # Returns true if any subsections are on day
      _.some @subsections, (subsection) ->
        subsection.isOnDay day

    isOverlapping: (other) ->
      for ts in @subsections
        for os in other.subsections
          if ts.isOverlapping os
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
