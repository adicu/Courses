angular.module('Courses.services')
.factory 'Course', ($http, $q, elasticSearch, Section) ->
  class Course
    @api_url = 'http://data.adicu.com/courses/v2/'
    @api_token = '515abdcf27200000029ca515'
    @elasticSearch = elasticSearch

    constructor: (@id, @semester, @ejs_data=null) ->
      if @ejs_data
        @title = @ejs_data.coursetitle
        @description = @ejs_data.description
        @points = @ejs_data.numfixedunits / 10.0

    fillData: () ->
      d = $q.defer()
      $http
        method: 'JSONP'
        url: Course.api_url + 'courses'
        params:
          course: @id
          term: @semester
          jsonp: 'JSON_CALLBACK'
          api_token: Course.api_token
      .success (datarecv, status, headers, config) =>
        d.resolve false if not datarecv.data
        @data = Course.convertAPItoEJS datarecv.data[0]

        @title = @data.coursetitle
        @description = @data.description or "No description given"
        @points = @data.numfixedunits / 10.0
        @hasMultipleSections = @data.sections.length > 1

        @getSections().then ->
          d.resolve true
      .error (data, status) ->
        d.resolve false
      d.promise

    getSections: () ->
      return if @sections and @sections.length >= 1
      d = $q.defer()
      @sections = []

      for sec in @data.sections
        if sec.Term == @semester
          s = new Section sec.CallNumber, @semester, sec, @
          @sections.push s

      promises = []
      for sec in @sections
        promises.push sec.fillData()

      $q.all(promises).then () =>
        @sections = @sections.filter (el) ->
          for subsec in el.subsections
            if subsec.length > 0
              return true
          return false
        d.resolve true
      d.promise

    @CUITCaseToUnderscore: (cuitcase) ->
      cuitcase = cuitcase.charAt(0).toLowerCase() + cuitcase.slice(1)
      return cuitcase.replace /([A-Z])/g, ($1) ->
        return "" + $1.toLowerCase()

    @convertAPItoEJS: (coursedata) ->
      for k,v of coursedata
        coursedata[Course.CUITCaseToUnderscore k] = v
      return coursedata