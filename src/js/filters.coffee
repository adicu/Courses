# Filters
angular.module("Courses.filters", [])
.filter 'toTwelveHours', ->
  (input) ->
    if input == 0
      return 'midnight'
    if input == 12
      return 'noon'
    if input < 12
      return input + 'am'
    if input > 12
      return (input - 12) + 'pm'
.filter 'readableSemester', ->
  (input) ->
    semesters = ['', 'Spring', 'Summer', 'Autumn']
    semester = input[input.length - 1]
    out = semesters[semester] + ' ' + input[0..3]
.filter 'readableDay', ->
  days =
    0: 'Monday',
    1: 'Tuesday',
    2: 'Wednesday',
    3: 'Thursday',
    4: 'Friday',
    5: 'Saturday',
    6: 'Sunday'
  (input) ->
    days[input]
.filter 'sectionOnDay', ->
  (sectionList, day) ->
    isonday = (sec) ->
      for d in sec.meetsOn
          if d == day
            return true
      false
    sec for sec in sectionList when isonday(sec)
