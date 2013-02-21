'use strict'

# Services


angular.module('Courses.services', [])
  .factory 'Course', ($http, $q) ->
    class Course
      constructor: (@id, @title, @description, @course_key,
          @num_sections, @semester) ->
        @sectionRefs = []

      getInfo: () =>
        return if @sections
        d = $q.defer()
        $http
          method: 'JSONP'
          url: 'http://courses.adicu.com/courses/get'
          params:
            course_key: @course_key
            s: @semester
            callback: 'JSON_CALLBACK'
        .success (data, status, headers, config) =>
          @points = data.points
          @sections = data.sections
          d.resolve this
        .error (data, status) ->
          d.reject status
        d.promise

      @search: (query, semester, length, page) ->
        d = $q.defer() # Create a new promise, to hide $http promise
        $http
          method: 'JSONP'
          url: 'http://courses.adicu.com/courses/search'
          params:
            q: query
            s: semester
            l: length
            p: page
            callback: 'JSON_CALLBACK'
        .success (data, status, headers, config) ->
          return if not data or not data.results
          out = []
          for result in data.results
            if result.title
              out.push new Course result.id, result.title, result.description,
                  result.course_key, result.num_sections, semester
          d.resolve out
        .error (data, status) ->
          d.reject status
        d.promise

      @getDays: (section) =>
        daysAbbr = "MTWRF"
        days = []
        daysStr = section.days
        for day in daysStr
          if daysAbbr.indexOf day isnt -1
            days.push(daysAbbr.indexOf day)
        days
  .factory 'Calendar', (Course) ->
    class Calendar
      constructor: () ->
        @courses = []
        @courseCalendar = []
        for i in [0..6]
          @courseCalendar[i] = []

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
        month = new Date().getMonth() + 1
        year = new Date().getFullYear()

        effectiveMonth = month + 1

        for i in [0..2]
          if effectiveMonth > 11
            effectiveMonth %= 12
            year++
          semester = Math.floor(effectiveMonth / 4) + 1
          effectiveMonth += 4
          semesters.push year + '' + semester
        semesters
      @hours: [8..23]
      @days: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']