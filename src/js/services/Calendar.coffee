angular.module('Courses.services')
.factory 'Calendar', (
  $location,
  $q,
  Course,
  CourseGraph,
  Section,
) ->
  class Calendar
    constructor: () ->
      @courseGraph = new CourseGraph

    getTotalPoints: () ->
      @courseGraph.getTotalPoints()

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
          CourseQuery.queryBySectionCall callnum, term

      $q.all(promises).then (sections) =>
        for section in sections
          @insertCourse section.parentCourse
        @updateURL()

    updateURL: () ->
      # TODO: implement
      return
      str = ''
      for key,section of sections
        if section
          str = str + section.data['CallNumber'] + ','
      if str and str.charAt(str.length - 1) == ','
        str = str.slice(0, -1)
      $location.hash ''
      $location.search('sections', str)

    # @return [Promise<Course>] | string Array of courses
    #   or string representing type of search.
    search: (query, term) ->
      d = $q.defer()
      if query.match /^\d{5}$/
        # Query is a section call number.
        callnum = parseInt query, 10
        Course.queryBySectionCall(callnum).then (course) ->
          @insertCourse course
        d.resolve 'callnum'
      else
        Course.query(query, term).then (data) ->
          d.resolve data
      d.promise

    insertCourse: (course) ->
      @courseGraph.insertCourse course

    sectionSelected: (section, shouldUpdateURL = true) ->
      section.selectSelf()
      @updateURL() if shouldUpdateURL

    getSectionArray: () ->
      @courseGraph.getSectionsByDay @getDays()

    getHours: ->
      return [8..23]

    getDays: ->
      return [0..4]
