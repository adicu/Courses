@Sections = new Meteor.Collection 'sections',
  schema: new SimpleSchema
    courseFull:
      type: String
      label: 'ex. COMSS3203'
      index: 1
    sectionFull:
      type: String
      label: 'ex. 20133COMS3203S001'
      index: 1
      unique: true
    callNumber:
      type: Number
    meetsOn:
      type: [String]
    building:
      type: [String]
    startTime:
      type: [String]
    endTime:
      type: [String]
    term:
      type: String
    instructors:
      type: String
    numEnrolled:
      type: Number
    room:
      type: [String]
    createdAt:
      CollectionsShared.createdAt

@Sections.helpers
  # Finds the Courses object associated with this Section
  getParentCourse: ->
    return Courses.findOne courseFull: @courseFull

  # Parses the time fields
  # @return [DateRange] - start, end
  # See moment-range package for info on DateRange
  # An array of start and end times based on the next Monday
  # after the start of classes for the current semester
  # Each meeting of class will generate one - MW => 2 starts and ends
  getMeetingTimes: ->
    # Next Monday after the current start date
    baseDate = Co.courseHelper.getCurrentSemesterDates().start.day(1)
    meetingTimes = []

    for meet, i in @meetsOn
      parsedDays = Co.courseHelper.parseDays @meetsOn[i]
      parsedStart = Co.courseHelper.parseTimes @startTime[i]
      parsedEnd = Co.courseHelper.parseTimes @endTime[i]
      # A field is missing
      # Possible error condition
      continue if not (parsedDays and parsedStart and parsedEnd)
      for day in parsedDays # ex. iterate over [M, W]
        newStart = moment baseDate # Copy the moment
        newEnd = moment baseDate
        # Set the day of the week, increment by 1 to account for
        # Sunday being 0 instead of Monday
        newStart.day day + 1
        newEnd.day day + 1

        newStart.hour(parsedStart[0]).minute(parsedStart[1])
        newEnd.hour(parsedEnd[0]).minute(parsedEnd[1])

        meetingTimes.push moment().range newStart, newEnd

    return meetingTimes

  # Converts this section to FullCalendar Event objects
  # @return [Event]
  toFCEvents: ->
    events = []
    title = @courseFull + ': ' +
      Co.toTitleCase @getParentCourse().courseTitle
    baseEvent =
      id: @sectionFull
      title: title
      courseFull: @courseFull
    for range in @getMeetingTimes()
      newEvent = _.extend {}, baseEvent,
        start: range.start.toISOString()
        end: range.end.toISOString()
        range: range
      events.push newEvent
    return events
