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
      @createSections()

      @id = @data.Course
      @points = @data.NumFixedUnits / 10.0

    createSections: () ->
      for sectionData in @data.sections
        section = new Section sectionData, @
        @addSection section

    addSection: (section) ->
      @sections.push section
      if section.isSelected()
        @selectedSections.push section

    selectSection: (section) ->
      return false if not section.isSelected()
      if _.findWhere(@selectedSections, callNumber: section.callNumber)
        # This section is already selected.
        # TODO: Error handling.
        return false
      else
        @selectedSections.push section

    isSelected: () ->
      new Boolean @selectedSections.length
