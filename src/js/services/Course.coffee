angular.module('Courses.services')
.factory 'Course', (
  $q,
  CoursesLoader,
  Section,
) ->
  class Course
    constructor: (@data) ->
      @sections = []
      @selectedSections = []

      @id = @data.Course
      @points = @data.NumFixedUnits / 10.0

      @createSections()

    createSections: () ->
      for sectionData in @data.sections
        section = new Section sectionData, @
        @addSection section

    addSection: (section) ->
      @sections.push section
      if section.isSelected()
        @selectedSections.push section

    # @return {Section} Returns section on success.
    selectSection: (section) ->
      return section if section.isSelected()
      if _.findWhere(@selectedSections, callNumber: section.callNumber)
        # This section is already selected.
        # TODO: Error handling.
        return false
      else
        @selectedSections.push section
      section

    # @return {Section} Returns section for call on success.
    selectSectionByCall: (callNumber) ->
      if _.findWhere(@selectedSections, callNumber: callNumber)
        # This section is already selected.
        # TODO: Error handling.
        return false
      else
        section = _.findWhere(@sections, callNumber: callNumber)
        @selectedSections.push section
      section

    # Returns selected sections for a given day.
    # @param number day int representing which day
    #   is wanted. 0 -> M, 1 -> T, etc.
    getSectionsByDay: (day) ->
      sectionsByDay =
        for section in @selectedSections
          if section.isSelectedForDay(day)
            section
          else
            continue

    isSelected: () ->
      new Boolean @selectedSections.length
