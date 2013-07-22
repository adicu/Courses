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
.filter 'readableDays', ->
  days =
    0: 'Sunday',
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday'
  (input) ->
    days[input]
