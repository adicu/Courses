'use strict'

# Services


angular.module('Courses.services', [])
  .factory 'Course', ($http, $q) ->
    class Course
      @api_url = 'http://data.adicu.com/courses'
      @api_token = '515abdcf27200000029ca515'

      constructor: (@data) ->
        return if not data.MeetsOn1?

        @id = data.CallNumber
        @title = data.CourseSubtitle
        @description = data.Description
        @course_key = data.Course
        @semester = data.Term
        @points = data.NumFixedUnits / 10.0

        #Fill in sections
        @sections = []
        @sections[0] =
          parentId: @id
          title: @title
          days: Course.parseDays @data.MeetsOn1
          points: @points
          start: Course.parseTime @data.StartTime1
          end: Course.parseTime @data.EndTime1

      getInfo: () =>
        d = $q.defer()
        return d.promise if @sections
        $http
          method: 'JSONP'
          url: Course.api_url
          params:
            course_key: @course_key
            term: @semester
            jsonp: 'JSON_CALLBACK'
        .success (data, status, headers, config) =>
          @points = data.points
          @sections = data.sections
          d.resolve this
        .error (data, status) ->
          d.reject status
        d.promise

      @search: (query, semester, length, page) =>
        d = $q.defer() # Override $http promise
        $http
          method: 'JSONP'
          url: Course.api_url
          params:
            description: query
            term: semester
            limit: length
            page: page
            jsonp: 'JSON_CALLBACK'
            api_token: Course.api_token
        .success (data, status, headers, config) ->
          return if not data.data
          out = []
          for result in data.data
            out.push new Course result
          d.resolve out
        .error (data, status) ->
          d.reject status
        d.promise

      @parseDays: (days) ->
        daysAbbr = "MTWRF"
        daysInt = []
        for day in days
          if daysAbbr.indexOf day isnt -1
            daysInt.push(daysAbbr.indexOf day)
        daysInt

      @parseTime: (time) ->
        hour = parseInt time.slice 0, 2
        minute = parseInt time.slice 3, 5
        intTime = hour + minute / 60.0
  .factory 'Calendar', (Course) ->
    class Calendar
      constructor: () ->
        @courses = {}
        @courseCalendar = []
        for i in [0..6]
          @courseCalendar[i] = []

      addCourse: (course) ->
        return if @courses[course.id]?
        @courses[course.id] = course

        sectionNum = 0 # Should be input
        section = course.sections[sectionNum]
        section.computedCss = Calendar.computeCss section.start,
            section.end
        for day in section.days
          console.log 'day: ' + day
          @courseCalendar[day].push section

      removeCourse: (section) ->
        id = section.id
        for i in [0..6]
          for section in @courseCalendar[i]

      showAllSections: (course) =>
        course.sectionRefs = []
        overlapCheck = {}
        for section in course.sections
          newSection =
            'id': section.id
            'computedCss': Calendar.computeCss(section.start, section.end)
            'title': section.title
            'points': course.points
            'days': Course.getDays(section) 
          overlap = overlapCheck[section.start + '' + section.end + section.days]
          if not overlap
            course.sectionRefs.push newSection
            overlapCheck[section.start + '' + section.end + section.days] = newSection
          else
            overlap.overlaps = [] if not overlap.overlaps
            overlap.overlaps.push newSection

        console.log course.sectionRefs
        console.log overlapCheck

        @courses.push(course)
        for section in course.sectionRefs
          for day in section.days
            @courseCalendar[day].push(section)

      @computeCss: (start, end) ->
        start_pixels = (start - Calendar.options.start_hour) * Calendar.options.pixels_per_hour
        height_pixels = Math.abs(end-start) * Calendar.options.pixels_per_hour

        return {
          "top": start_pixels
          "height": height_pixels
        }

      @options:
        pixels_per_hour: 42
        start_hour: 8
        
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