angular.module('Courses.services')
.factory 'Section', (
  CourseHelper,
) ->
  class Section
    constructor: (@data, @parentCourse) ->
      @subsections = []
      @selected = false

      @callNumber = @data.CallNumber
      @id = @parentCourse.id
      @idFull = @parentCourse.idFull
      @points = @parentCourse.points
      @title = @parentCourse.title

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

    isSelectedForDay: (day) ->
      for subsection in @subsections
        for meetDay in subsection.meetsOn
          if meetDay == day
            return true
      return false

    selectSelf: () ->
      @selected = true
      if @parentCourse
        @parentCourse.selectSection @

