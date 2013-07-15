angular.module('Courses.services')
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
      if $location.search().hasOwnProperty('sections')
        callnum_string = ($location.search()).sections
      else
        # hash rather than empty to support legacy routes
        callnum_string = $location.hash()
      callnums = if callnum_string then callnum_string.split ',' else []

      sections = for callnum in callnums
        if callnum?
          sec = new Section callnum, semester
        else
          continue

      promises = for sec in sections
        sec.fillData Course

      $q.all(promises).then =>
        for sec in sections
          @sectionChosen sec
        @updateURL()

    updateURL: () ->
      str = ""
      for key,section of @sections
        if section
          str = str + section.data['CallNumber'] + ","
      if str and str.charAt(str.length - 1) == ','
        str = str.slice(0, -1)
      $location.hash ''
      $location.search('sections', str)

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
      if section.parent
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
