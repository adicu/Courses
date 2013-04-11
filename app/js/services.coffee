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
        if @description == null
          @description = "No description given"
        @points = data.numfixedunits / 10.0

      @CUITCaseToUnderscore: (cuitcase) ->
        cuitcase = cuitcase.charAt(0).toLowerCase() + cuitcase.slice(1)
        return cuitcase.replace /([A-Z])/g, ($1) ->
          return "" + $1.toLowerCase()

      @convertAPItoEJS: (coursedata) ->
        for k,v of coursedata
          coursedata[Course.CUITCaseToUnderscore k] = v
        return coursedata

      @addSectionFromCallNumber: (call, semester, cal) ->
        d = $q.defer() # Override $http promise
        $http
          method: 'JSONP'
          url: Course.api_url + 'sections'
          params:
            call_number: call
            term: semester
            jsonp: 'JSON_CALLBACK'
            api_token: Course.api_token
        .success (data, status, headers, config) ->
          return null if not data.data
          section = Course.convertAPItoEJS data.data[0]

          # do more derpy stuff to get the course num
          d2 = $q.defer()
          $http
            method: 'JSONP'
            url: Course.api_url + 'courses'
            params:
              course: section.Course
              term: section.term
              jsonp: 'JSON_CALLBACK'
              api_token: Course.api_token
          .success (data2, status, headers, config) ->
            return null if not data.data
            
            coursedata = Course.convertAPItoEJS data2.data[0]
            
            c = new Course coursedata, section.term
            c.getSections().then (status) ->
              return if not status
              for sec in c.sections
                if sec.data.CallNumber.toString() == call.toString()
                  cal.sectionChosen sec, false

            d2.resolve true
          .error (data, status) ->
            d2.resolve false
          d2.promise

          d.resolve true
        .error (data, status) ->
          d.resolve false
        d.promise

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
            .must(ejs.QueryStringQuery(query + '*')
              .fields(['coursetitle^3', 'course^4', 'description',
                'coursesubtitle', 'instructor^2']))
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

  .factory 'Calendar', ($http, $q, Course, $location) ->
    class Calendar
      constructor: () ->
        @courses = {}
        @sections = {}
        @courseCalendar = []
        for i in [0..6]
          @courseCalendar[i] = []

      fillFromURL: (semester) ->
        console.log $location.hash()
        callnums = $location.hash().split ','
        for callnum in callnums
          if callnum != ''
            Course.addSectionFromCallNumber callnum, semester, @

      updateURL: () ->
        str = ""
        for key,section of @sections
          if section
            str = str + section.data['CallNumber'] + ","
        if str and str.charAt(str.length - 1) == ','
          str = str.slice(0, -1)
        if $location.hash() != str
          $location.hash str

      addCourse: (course) ->
        return if @courses[course.id] or course.sections.length < 1

        if course.sections.length > 1
          @showAllSections course
        else
          @sectionChosen course.sections[0]
          @updateURL()

      addSection: (section, canoverlap=true) ->
        @courses[section.id] = section.parent

        console.log section
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
        # @updateURL() 

      sectionChosen: (section, updateurl=true) ->
        section.parent.status = null
        @removeCourse section.id
        @sections[section.id] = section
        @addSection(section, false)
        console.log section
        # if updateurl
        # @updateURL() 

      showAllSections: (course) =>
        course.status = "overlapping"
        for section in course.sections
          @addSection section

      changeSections: (course) ->
        console.log course
        @removeCourse course.id
        @showAllSections course
        
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
