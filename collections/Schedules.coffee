@Schedules = new Meteor.Collection 'schedules',
  schema: new SimpleSchema
    addedCourses:
      type: [Object]
      optional: true
    'addedCourses.$.course':
      type: String
      label: 'CourseFull reference'
    'addedCourses.$.color':
      type: String
      label: 'Color associated with course'
    addedSections:
      type: [Object]
      optional: true
    'addedSections.$.section':
      type: String
      label: 'SectionFull reference'
    semester:
      type: Number
    createdAt:
      CollectionsShared.createdAt
    updatedAt:
      CollectionsShared.updatedAt
    owner:
      CollectionsShared.owner

# Allow / Deny

@Schedules.allow
  insert: (userId, doc) ->
    # (semester, owner) consistency may be
    # need to be enforced here
    userId and doc.owner == userId
  update: (userId, doc, fields, modifier) ->
    doc.owner == userId
  remove: (userId, doc) ->
    doc.owner == userId
  fetch: ['owner']

# Helpers

@Schedules.helpers
  addCourse: (courseFull, callback) ->
    Meteor.subscribe 'courses', courseFull, =>
      course = Courses.findOne courseFull: courseFull

      if not course
        if callback
          callback new Error 'This course does not exist'
        return

      Schedules.update @_id,
        $push:
          addedCourses:
            course: courseFull
            color: @randomUniqueColor()
      , null # options
      , callback

      sections = Sections.find
        courseFull: courseFull
        term: Session.get 'currentSemester'
      .fetch()
      if sections.length == 1
        @addSection sections[0].sectionFull

  addSection: (sectionFull) ->
    Schedules.update @_id,
      $push:
        addedSections:
          section: sectionFull

  # Removes course and all related sections from the schedule
  removeCourse: (courseFull) ->
    Schedules.update @_id,
      $pull:
        addedCourses:
          course: courseFull

    sectionFulls = _.pluck @getSectionsForCourse(courseFull), 'sectionFull'
    return if not sectionFulls
    sectionFulls = _.map sectionFulls, (sectionFull) ->
      section: sectionFull
    Schedules.update @_id,
      $pullAll:
        addedSections: sectionFulls

  removeSection: (sectionFull) ->
    Schedules.update @_id,
      $pull:
        addedSections:
          section: sectionFull

  # @return [Course]
  getCourses: ->
    courses = @getCourseFulls()
    return Courses.find
      courseFull:
        $in: courses
    , sort: ['course']

  # @return [Section]
  getSections: ->
    sections = @getSectionFulls()
    return Sections.find
      sectionFull:
        $in: sections
      term: Session.get 'currentSemester'

  # @return [Section] The sections that are
  # associated with a given courseFull
  getSectionsForCourse: (courseFull) ->
    sections = @getSections().fetch()
    return _.filter sections, (section) ->
      return section.courseFull == courseFull

  isSelected: (sectionFull) ->
    return _.contains @getSectionFulls(), sectionFull

  # @return [String] courseFulls
  getCourseFulls: ->
    courses = _.pluck @addedCourses, 'course'

  # @return [String] sectionFulls
  getSectionFulls: ->
    sections = _.pluck @addedSections, 'section'

  getTotalPoints: ->
    totalPoints = 0
    sectionFulls = @getSectionFulls()
    selectedCourseFulls = _.map sectionFulls, (item) ->
      Co.courseHelper.sectionFulltoCourseFull item
    selectedCourseFulls = _.uniq selectedCourseFulls
    for course in @getCourses().fetch()
      if _.contains selectedCourseFulls, course.courseFull
        totalPoints += course.numFixedUnits / 10
    totalPoints

  # @return String a color which is attempted to be unique
  randomUniqueColor: ->
    usedColors = _.pluck @addedCourses, 'color'
    unusedColors = _.difference Co.courseHelper.colors, usedColors
    if not unusedColors
      # If all colors have been used
      unusedColors = Co.courseHelper.colors
    return _.sample unusedColors

  # @return [String] the color associated with a given courseFull
  getColor: (courseFull) ->
    addedCourse = _.find @addedCourses, (course) ->
      course.course == courseFull
    if addedCourse
      return addedCourse.color

  # Converts all included sections to FullCalendar Event objects
  # @return [Event]
  toFCEvents: ->
    sections = @getSections().fetch()
    events = (section.toFCEvents() for section in sections)
    events = _.flatten events
    return events
