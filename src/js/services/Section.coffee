angular.module('Courses.services')
.factory 'Section', ($http, $q) ->
  class Section
    @api_url = 'http://data.adicu.com/courses/v2/'
    @api_token = '51ffc99d0b18dc0002859b8d'

    constructor: (callnum, @semester, @data=null, @parent=null) ->
      @call = callnum
      @semester = @semester
      @data = @data
      @parent = @parent

    getCourse: ->
      parent = @parent
      while parent
        return parent if parent instanceof Course
        parent = parent.parent
      return null

    fillParent: (Course) ->
      d = $q.defer()
      if @parent == null
        @parent = new Course @data.Course, @semester
        @parent.fillData().then (status) ->
          d.resolve true
      else
        d.resolve true
      d.promise

    getData: () ->
      return if @subsections and @subsections.length >= 1
      d = $q.defer()
      if not @data
        $http
          method: 'JSONP'
          url: Section.api_url + 'sections'
          params:
            call_number: @call
            term: @semester
            jsonp: 'JSON_CALLBACK'
            api_token: Section.api_token
        .success (data, status, headers, config) =>
          return d.resolve false if not data.data
          @data = data.data[0]

          d.resolve true
        .error (data, status) ->
          d.reject false
      else
        d.resolve true
      d.promise

    fillData: (Course) ->
      return if @subsections and @subsections.length >= 1
      d = $q.defer()
      @getData().then =>
        @call = @call
        @id = @data.Course

        @fillParent(Course).then =>
          @subsections = []
          for i in [0..6]
            @subsections[i] = []
          @parseDayAndTime()
          @urlFromSectionFull @data.SectionFull
          @instructor = @data.Instructor1Name.split(',')[0]
          d.resolve true
      d.promise

    urlFromSectionFull: (sectionfull) ->
      re = /([a-zA-Z]+)(\d+)([a-zA-Z])(\d+)/g
      cu_base = 'http://www.columbia.edu/cu/bulletin/uwb/subj/'
      @url = sectionfull.replace re, cu_base + '$1/$3$2-'+ @data.Term + '-$4'
      @sectionNum = sectionfull.replace re, '$4'

    parseDayAndTime: ->
      for i in [1..2]
        continue if not @data['MeetsOn' + i]
        for day in Section.parseDays @data['MeetsOn' + i]
          start = Section.parseTime @data['StartTime' + i]
          end = Section.parseTime @data['EndTime' + i]
          if day >= 0 and day <= 6
            @subsections[day].push
              id: @id
              title: @parent.title
              instructor: @data.Instructor1Name
              parent: @
              day: day
              start: start
              end: end
              css: Section.computeCss start, end

    overlapCheck: (calendar, dayNum) ->
      days = dayNum or [0..6]
      count = 0
      for day in days
        for subsection in @subsections[day]
          for entry in calendar[day]
            if subsection.start <= entry.end and
                subsection.end >= entry.start
              return true
      return false

    @parseDays: (days) ->
      return if not days?
      daysAbbr = Section.options.daysAbbr
      for day in days
        if daysAbbr.indexOf day isnt -1
          daysAbbr.indexOf day

    @parseTime: (time) ->
      return if not time?
      hour = parseInt (time.slice 0, 2), 10
      minute = parseInt (time.slice 3, 5), 10
      intTime = hour + minute / 60.0

    @computeCss: (start, end) ->
      return if not start?
      top_pixels = Math.abs(start -
          Section.options.start_hour) * Section.options.pixels_per_hour +
          Section.options.top_padding
      height_pixels = Math.abs(end-start) * Section.options.pixels_per_hour

      return {
        "top": top_pixels
        "height": height_pixels
      }

    @options:
      pixels_per_hour: 38
      start_hour: 8
      top_padding: 38
      daysAbbr: "MTWRF"