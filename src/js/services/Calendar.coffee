angular.module('Courses.services')
.factory 'Calendar', (
  Course,
  CourseGraph,
  CourseQuery,
  Section,
  CalendarUtil,
  $q,
) ->
  class Calendar
    constructor: () ->
      @courseGraph = new CourseGraph

    totalPoints: () ->
      @courseGraph.getTotalPoints()

    fillFromURL: (semester) ->
      promise = CalendarUtil.fillFromURL semester
      $q.all(promise).then (sections) =>
        console.log sections
        for sec in sections
          @sectionSelected sec
        @updateURL()

    updateURL: () ->
      CalendarUtil.updateURL @sections

    search: (query, semester) ->
      d = $q.defer()
      if query.match /^\d{5}$/
        callnum = parseInt query, 10
        CourseQuery.getCourseFromCall(callnum).then (course) ->
          CourseGraph.insertCourse course
        d.resolve 'callnum'
      else
        CourseQuery.query(query, semester).then (results) ->
          for result in results
            new Course result._source.course, semester, result._source
        d.resolve results
      d.promise

    sectionSelected: (section, shouldUpdateURL=true) ->
      section.setSelfChosen
      @updateURL() if shouldUpdateURL

    @fillFromURL: (semester) ->
      if $location.search().hasOwnProperty('sections')
        callnum_string = ($location.search()).sections
      else
        # hash rather than empty to support legacy routes
        callnum_string = $location.hash()
      callnums = if callnum_string then callnum_string.split ',' else []

      sections = for callnum in callnums
        if callnum?
          sec = new Section callnum, semester

      promises = for sec in sections
        sec.fillData Course

    @updateURL: (sections) ->
      str = ''
      for key,section of sections
        if section
          str = str + section.data['CallNumber'] + ','
      if str and str.charAt(str.length - 1) == ','
        str = str.slice(0, -1)
      # $location.hash ''
      $location.search('sections', str)

    @getHours: ->
      return [8..23]

    @getDays: ->
      ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
