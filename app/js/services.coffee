'use strict'

# Services


angular.module('Courses.services', [])
  .factory 'Course', ($http, $q, ejsResource, Section) ->
    class Course
      @api_url = 'http://data.adicu.com/courses/v2/'
      @api_token = '515abdcf27200000029ca515'
      @ejs = ejsResource('http://db.data.adicu.com:9200')
      window.ej = @ejs
      @request = ejs.Request()
                    .indices('jdbc')

      constructor: (@data, @semester) ->
        @id = data.course
        @title = data.coursetitle
        @description = data.description
        @points = data.numfixedunits / 10.0

      getSections: ->
        return if @sections and @sections.length >= 1
        d = $q.defer() # Override $http promise
        $http
         method: 'JSONP'
         url: Course.api_url + 'sections'
         params:
          course: @id
          term: @semester
          jsonp: 'JSON_CALLBACK'
          api_token: Course.api_token
        .success (data, status, headers, config) =>
          return if not data.data
          @sections = []
          for section in data.data
            @sections.push new Section section, @
          d.resolve true
        .error (data, status) ->
          d.resolve false
        d.promise

      @search: (query, semester, length, page) ->
        Course.request
          .query(
            ejs.BoolQuery()
            .must(ejs.WildcardQuery('term', '*' + semester  + '*'))
            .must(ejs.QueryStringQuery(query)
              .fields(['coursetitle^3', 'course^4', 'description',
                'coursesubtitle']))
          )
          .doSearch().then (data) ->
            return if not data.hits? and data.hits.hits?
            hits = data.hits.hits
            new Course hit._source, semester for hit in hits


  .factory 'Section', () ->
    class Section
      constructor: (@data, @parent) ->
        @id = data.Course
        @subsections = []
        for i in [0..6]
          @subsections[i] = []
        @parseDayAndTime()

      parseDayAndTime: ->
        for i in [1..2]
          continue if not @data['MeetsOn' + i]
          for day in Section.parseDays @data['MeetsOn' + i]
            start = Section.parseTime @data['StartTime' + i]
            end = Section.parseTime @data['EndTime' + i]
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
        hour = parseInt time.slice 0, 2
        minute = parseInt time.slice 3, 5
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
        top_padding: 31
        daysAbbr: "MTWRF"


  .factory 'Calendar', (Course) ->
    class Calendar
      constructor: () ->
        @courses = {}
        @courseCalendar = []
        for i in [0..6]
          @courseCalendar[i] = []

      addCourse: (course) ->
        return if @courses[course.id] or course.sections.length < 1

        if course.sections.length > 1
          @showAllSections course
        else
          @addSection course.sections[0]

      addSection: (section) ->
        @courses[section.id] = section.parent

        if section.overlapCheck @courseCalendar
          console.log 'Overlap'
          # return
        for day, i in section.subsections
          for subsection in day
            @courseCalendar[i].push subsection

      removeCourse: (id) ->
        for day, i in @courseCalendar
          @courseCalendar[i] = @courseCalendar[i].filter (subsection) ->
            if subsection.id == id
              return false
            return true
        @courses[id] = false

      sectionChosen: (section) ->
        @removeCourse section.id
        @addSection section

      showAllSections: (course) =>
        console.log 'showAll'

        course.status = "overlapping"
        for section in course.sections
          @addSection section
        
      @getValidSemesters: ->
        semesters = []
        month = new Date().getMonth()
        year = new Date().getFullYear()

        effectiveMonth = month + 2

        for i in [0..2]
          if effectiveMonth > 11
            effectiveMonth %= 12
            year++
          semester = Math.floor(effectiveMonth / 4) + 1
          effectiveMonth += 4
          semesters.push year + '' + semester
        semesters
        semesters = ['20133', '20141']
      @hours: [8..23]
      @days: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']