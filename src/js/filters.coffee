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
    if h == 12
      ampm = 'pm'
    else if h > 12
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
    if data[3].toLowerCase() == "x"
      data[3] = "BC"
    course = data[3] + data[2]
    sectno = data[4]

    baseurl = 'http://www.columbia.edu/cu/bulletin/uwb/subj/'
    baseurl + dept + '/' + course + '-' + term + '-' + sectno + '/'
.filter 'culpaLink', ->
  (section) ->
    if section.instructor == ''
      return 'TBD'
    csv =  section.instructor.split(',')
    csv[0] = csv[0].trim()
    csv[1] = csv[1].trim()
    firstmiddle = csv[1].split(' ')
    query = firstmiddle[0] + ' ' + csv[0]
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
.filter 'zeropad', ->
  (num, padding) ->
    num = num + ''
    return if num.length >= padding then num else new Array(padding - num.length + 1).join('0') + num
.filter 'titleCase', ->
  (str) ->
    titleCaseRegex = /\w\S*/g
    return str.replace titleCaseRegex, (txt) ->
      return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

.filter 'calByDay', ->
  days =
    0: 'MO',
    1: 'TU'
    2: 'WE'
    3: 'TH'
    4: 'FR',
  (input) ->
    days[input]
