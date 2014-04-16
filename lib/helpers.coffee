@Co = {} if not @Co?
# Co is used just as a short namespace for methods
# relating to the Courses application

# Helpers particularly related to Courses
@Co.courseHelper =
  # Converts days of format MTWRF into ints.
  # M => 0, W => 2, etc.
  parseDays: (days) ->
    return if not days
    daysAbbr = @getOptions().daysAbbr
    parsed = []
    for day in days
      if daysAbbr.indexOf(day) isnt -1
        parsed.push daysAbbr.indexOf day
      else
        return null
    return parsed

  # Parses times into hours and minutes
  # @param [String] ex. ["0815"]
  # @return [Number, Number] ex. [8, 15]
  parseTimes: (time) ->
    # Ignore times of non length 4
    return if not time or time.length isnt 4
    hour = parseInt time.slice(0, 2), 10
    min = parseInt time.slice(2), 10
    return [hour, min]

  getOptions: () ->
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

    return "#{subject}#{courseType}#{courseNumber}"

  urlFromSectionFull: (sectionFull) ->
    re = /([a-zA-Z]+)(\d+)([a-zA-Z])(\d+)/g
    cu_base = 'http://www.columbia.edu/cu/bulletin/uwb/subj/'
    @url = sectionFull.replace re, cu_base + '$1/$3$2-'+ @data.Term + '-$4'
    @sectionNum = sectionFull.replace re, '$4'

  # Return {start: Moment, end: Moment} Object indicating
  # the start and end dates for the current semester
  getCurrentSemesterDates: ->
    currentSemester = Number Session.get 'currentSemester'
    return if not currentSemester
    return Co.constants.semesterDates[currentSemester]

  colors: [
    "red"
    "orange"
    "yellow"
    "green"
    "forest"
    "blue"
    "midnight"
    "purple"
  ]

@Co.toTitleCase = (str) ->
  titleCaseRegex = /\w\S*/g
  return str.replace titleCaseRegex, (txt) ->
    return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

# Necessary for anon users package
# Returns the current user object
@Co.user = ->
  if Meteor.user()
    return Meteor.user()

  if Meteor.userId()
    return Meteor.users.findOne Meteor.userId()
  else
    return null
