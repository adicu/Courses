@Co = {} if not @Co?

@Co.courseHelper =
  # Converts days of format MTWRF into ints.
  # M => 0, W => 2, etc.
  parseDays: (days) ->
    return if not days?
    daysAbbr = @getOptions().daysAbbr
    for day in days
      if daysAbbr.indexOf day isnt -1
        daysAbbr.indexOf day

  # Converts time to floats for display purposes
  # 0815 => 8.25
  parseTime: (time) ->
    return if not time?
    hour = parseInt (time.slice 0, 2), 10
    minute = parseInt (time.slice 3, 5), 10
    floatTime = hour + minute / 60.0

  getOptions: () ->
    pixelsPerHour: 38
    startHour: 8
    topPadding: 38
    daysAbbr: "MTWRF"
    specialFields: [
      'Building',
      'EndTime',
      'MeetsOn',
      'Room',
      'StartTime'
    ]

  # Converts from sectionFull format to courseFull format
  # ex. COMSS3203 to 20133COMS3203S001
  sectionFulltoCourseFull: (sectionFull) ->
    subject = sectionFull.slice 5, 9
    courseNumber = sectionFull.slice 9, 13
    courseType = sectionFull[13]

    return "#{subject} #{courseType}#{courseNumber}"

  urlFromSectionFull: (sectionFull) ->
    re = /([a-zA-Z]+)(\d+)([a-zA-Z])(\d+)/g
    cu_base = 'http://www.columbia.edu/cu/bulletin/uwb/subj/'
    @url = sectionFull.replace re, cu_base + '$1/$3$2-'+ @data.Term + '-$4'
    @sectionNum = sectionFull.replace re, '$4'

  computeCSS: (start, end) ->
    return if not start?
    options = @getOptions()
    top_pixels = Math.abs(start -
        options.startHour) * options.pixelsPerHour +
        options.topPadding
    height_pixels = Math.abs(end-start) * options.pixelsPerHour

    top: top_pixels
    height: height_pixels

  getValidSemesters: ->
    semesters = []
    date = new Date()
    month = date.getMonth()
    year = date.getFullYear()

    effectiveMonth = month + 2

    for i in [0..2]
      if effectiveMonth > 11
        effectiveMonth %= 12
        year++
      semester = Math.floor(effectiveMonth / 4) + 1
      effectiveMonth += 4
      semesters.push year + '' + semester
    semesters
