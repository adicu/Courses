angular.module('Courses.services')
.factory 'Calendar', (
  Course,
  Section,
  CalendarUtil,
  $q,
) ->
  class Calendar
    constructor: () ->
      @courseGraph = new CourseGraph

    totalPoints: () ->
      @courseGraph.totalPoints()

    fillFromURL: (semester) ->
      promise = CalendarUtil.fillFromURL semester
      $q.all(promise).then (sections) =>
        console.log sections
        for sec in sections
          @sectionChosen sec
        @updateURL()

    updateURL: () ->
      CalendarUtil.updateURL @sections

    search: (query, semester) ->
      d = $q.defer()
      if query.match /^\d{5}$/
        callnum = parseInt query, 10
        s = new Section callnum, semester
        s.fillData(Course).then (status) ->
          calendar.sectionChosen s
          calendar.updateURL()
        d.resolve 'callnum'
      else
        CalendarUtil.runCourseQuery().then (results) ->
          for result in results
            new Course result._source.course, semester, result._source
        d.resolve results
      d.promise

    addSection: (section, canoverlap=true) ->
      @courses[section.id] = section.parent

      if section.overlapCheck @courseCalendar
        if !canoverlap
          alert 'Warning: this overlaps with a course you have already selected'
          # return false
      for day, i in section.subsections
        for subsection in day
          @courseCalendar[i].push subsection
      return true

    removeCourse: (id) ->
      for day, i in @courseCalendar
        @courseCalendar[i] = @courseCalendar[i].filter (subsection) ->
          if subsection.id == id
            return false
          return true
      @courses[id] = false
      @sections[id] = false

    sectionChosen: (section, shouldUpdateURL=true) ->
      if section.parent
        section.parent.status = null
      @removeCourse section.id
      @sections[section.id] = section
      @addSection(section, false)
      @updateURL() if shouldUpdateURL

    showAllSections: (course) =>
      course.status = "overlapping"
      for section in course.sections
        @addSection section

    changeSections: (course) ->
      @removeCourse course.id
      @showAllSections course

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

    @runCourseQuery: (query) ->
      d = $q.defer()
      elasticSearch
        .query(
            ejs.BoolQuery()
            .must(ejs.WildcardQuery('term', '*' + semester  + '*'))
            .should(ejs.QueryStringQuery(query + '*')
              .fields(['coursetitle^3', 'course^4', 'description',
                'coursesubtitle', 'instructor^2']))
            .should(ejs.QueryStringQuery('*' + query + '*')
              .fields(['course', 'coursefull']))
            .minimumNumberShouldMatch(1)
        )
        .doSearch()
        .then (data) ->
          processedResults = CalendarUtil.processQueryResults data
          d.resolve processedResults
      d.promise

    @processQueryResults: (data) ->
      return if not data? and not data.hits? and data.hits.hits?
      results = data.hits.hits

    @getValidSemesters: ->
      semesters = []
      date = new Date()
      month = date.getMonth()
      year = date.getFullYear()

      effectiveMonth = month + 2

      for i in [0..2]
        if effectiveMonth > 11
          effectiveMonth %= 12
          year++
        semester = Math.floor(effectiveMonth / 4) + 1
        effectiveMonth += 4
        semesters.push year + '' + semester
      semesters

    @getHours: ->
      return [8..23]

    @getDays: ->
      ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
