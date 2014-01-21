angular.module('Courses.models')
.factory 'Subsection', (
  CourseHelper,
) ->
  class Subsection
    # Field examples:
    # building: "PUPIN LABORA"
    # endTime: 12.25
    # meetsOn: [0, 2]
    # points: 3
    # room: "301"
    # startTime: 11
    constructor: (@data) ->
      # Set all of the properties on data to the new object
      _.extend @, @data
      @computeCSS()

    computeCSS:  ->
      @css = CourseHelper.computeCSS @startTime, @endTime

    isOnDay: (day) ->
      _.indexOf(@meetsOn, day) isnt -1

    isOverlapping: (other) ->
      if not (@endTime < other.startTime or other.endTime < @startTime)
        for thisDay in @meetsOn
          if other.isOnDay thisDay
            return true
      return false

    # Will reset the CSS of the subsection
    reset: ->
      @css.width = "100%"
      @css.left = "0"

    # Recalc the CSS for multiple overlapping sections
    @recalcCSS: (overlappingSubsections) ->
      overlappingSubsections = _.sortBy overlappingSubsections,
        (section) ->
          section.id
      currentLeft = 0
      width = 100 / overlappingSubsections.length
      for subsection in overlappingSubsections
        subsection.css.width = "#{width}%"
        subsection.css.left = "#{currentLeft}%"
        currentLeft += width
