angular.module('Courses.services')
  .factory 'CalendarUtil', (
    $http,
    $location,
    $q,
    Course,
    Section,
    elasticSearch,
) ->
  class CalendarUtil
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

    @search: (calendar, query, semester) ->
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