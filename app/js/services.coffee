'use strict'

# Services


angular.module('Courses.services', []).
  service 'Semester', ->
    @getValidSemesters = ->
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