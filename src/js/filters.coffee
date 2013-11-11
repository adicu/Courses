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
.filter 'readableTime', ->
  (time) ->
    time_re = /(\d+):(\d+):(\d+)/
    d = time.match time_re
    if d == null
      return time
    h = d[1]
    m = d[2]
    s = d[3]
    ampm = 'am'
    if h > 12
      h = h - 12
      ampm = 'pm'
    time = h + ':' + m + ' ' +  ampm
    time

.filter 'bulletinLink', ->
  (section) ->
    section_re = /([A-Z]+)(\d+)([A-Z]+)(\d+)/

    data = section.data.SectionFull.match(section_re)
    term = section.data.Term
    dept = data[1]
    course = data[3] + data[2]
    sectno = data[4]

    baseurl = 'http://www.columbia.edu/cu/bulletin/uwb/subj/'
    baseurl + dept + '/' + course + '-' + term + '-' + sectno + '/'
.filter 'culpaLink', ->
  (section) ->
    if section.instructor == ''
      return 'TBD'
    csv =  section.instructor.split(',')
    query = csv[1].trim() + ' ' + csv[0].trim()
    baseurl = 'http://culpa.info/search/results?search='
    baseurl + encodeURIComponent(query)
.filter 'sectionOnDay', ->
  (sectionList, day) ->
    isonday = (sec) ->
      for d in sec.meetsOn
          if d == day
            return true
      false
    sec for sec in sectionList when isonday(sec)
