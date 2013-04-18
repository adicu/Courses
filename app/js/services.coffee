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

      constructor: (@id, @semester, @ejs=null) ->
        @id = @id
        @semester = @semester
        if @ejs != null
          @title = @ejs.coursetitle
          @description = @ejs.description
          @points = @ejs.numfixedunits / 10.0

      fillData: () ->
        ptr = @
        d = $q.defer()
        $http
          method: 'JSONP'
          url: Course.api_url + 'courses'
          params:
            course: @id
            term: @semester
            jsonp: 'JSON_CALLBACK'
            api_token: Course.api_token
        .success (datarecv, status, headers, config) ->
          return null if not datarecv.data
          ptr.data = Course.convertAPItoEJS datarecv.data[0]

          ptr.title = ptr.data.coursetitle
          ptr.description = ptr.data.description
          if ptr.description == null
            ptr.description = "No description given"
          ptr.points = ptr.data.numfixedunits / 10.0

          d.resolve true
        .error (data, status) ->
          d.resolve false
        d.promise

      @CUITCaseToUnderscore: (cuitcase) ->
        cuitcase = cuitcase.charAt(0).toLowerCase() + cuitcase.slice(1)
        return cuitcase.replace /([A-Z])/g, ($1) ->
          return "" + $1.toLowerCase()

      @convertAPItoEJS: (coursedata) ->
        for k,v of coursedata
          coursedata[Course.CUITCaseToUnderscore k] = v
        return coursedata

      getSections: () ->
        return if @sections and @sections.length >= 1
        ptr = @
        d = $q.defer()
        ptr.sections = []

        for sec in ptr.data.sections
          if sec.Term == ptr.semester
            s = new Section sec.CallNumber, ptr.semester, sec, ptr
            ptr.sections.push s

        promises = []
        for sec in ptr.sections
          promises.push sec.fillData()

        $q.all(promises).then () ->
          ptr.sections = ptr.sections.filter (el) ->
            for subsec in el.subsections
              if subsec.length > 0
                return true
            return false

          d.resolve true
        d.promise

      @search: (query, semester, calendar, clearResults) ->
        if query.match /^\d{5}$/
          callnum = parseInt query, 10
          s = new Section callnum, semester
          s.fillData(Course).then (status) ->
            calendar.sectionChosen s
            calendar.updateURL()
            clearResults()
        else
          Course.request
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
            .doSearch().then (data) ->
              return if not data.hits? and data.hits.hits?
              hits = data.hits.hits
              new Course hit._source.course, semester, hit._source for hit in hits

  .factory 'Section', ($http, $q) ->
    class Section
      @api_url = 'http://data.adicu.com/courses/v2/'
      @api_token = '515abdcf27200000029ca515'

      constructor: (callnum, @semester, @data=null, @parent=null) ->
        @call = callnum
        @semester = @semester
        @data = @data
        @parent = @parent

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
        ptr = @
        d = $q.defer()
        if not ptr.data
          $http
            method: 'JSONP'
            url: Section.api_url + 'sections'
            params:
              call_number: @call
              term: @semester
              jsonp: 'JSON_CALLBACK'
              api_token: Section.api_token
          .success (data, status, headers, config) ->
            return d.resolve false if not data.data
            ptr.data = data.data[0]

            d.resolve true
          .error (data, status) ->
            d.reject false
        else
          d.resolve true
        d.promise
        
      fillData: (Course=null) ->
        return if @subsections and @subsections.length >= 1
        ptr = @
        d = $q.defer()
        ptr.getData().then ->
          ptr.call = ptr.call
          ptr.id = ptr.data.Course

          ptr.fillParent(Course).then ->
            ptr.subsections = []
            for i in [0..6]
              ptr.subsections[i] = []
            ptr.parseDayAndTime()
            ptr.urlFromSectionFull ptr.data.SectionFull
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

  .factory 'Calendar', ($http, $q, Course, Section, $location) ->
    class Calendar
      constructor: () ->
        @courses = {}
        @sections = {}
        @courseCalendar = []
        for i in [0..6]
          @courseCalendar[i] = []

      totalPoints: () ->
        points = 0
        for key,course of @courses
          if course
            points += course.points
        return points

      fillFromURL: (semester) ->
        ptr = @
        console.log $location.hash()
        callnums = $location.hash().split ','

        arr = []
        for callnum in callnums
          if callnum != ''
            j = new Section callnum, semester
            if j != null
              arr.push j

        arr2 = []
        for sec in arr
          arr2.push sec.fillData(Course)

        $q.all(arr2).then ->
          for sec in arr
            console.log 'choosing ' + sec.call
            ptr.sectionChosen sec

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
        if @courses[course.id]
          alert 'Warning: you have already selected this course'
          return
        if course.sections.length < 1
          alert 'Warning: this course has no scheduled sections'
          return

        if course.sections.length > 1
          @showAllSections course
        else
          @sectionChosen course.sections[0]
          @updateURL()

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

      sectionChosen: (section, updateurl=true) ->
        section.parent.status = null
        @removeCourse section.id
        @sections[section.id] = section
        @addSection(section, false)

      showAllSections: (course) =>
        course.status = "overlapping"
        for section in course.sections
          @addSection section

      changeSections: (course) ->
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
