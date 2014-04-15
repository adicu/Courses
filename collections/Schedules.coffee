@Schedules = new Meteor.Collection 'schedules',
  schema: new SimpleSchema
    addedCourses:
      type: [Object]
      optional: true
    'addedCourses.$.course':
      type: String
      label: 'CourseFull reference'
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
    userId and doc.owner == userId
  update: (userId, doc, fields, modifier) ->
    doc.owner == userId
  remove: (userId, doc) ->
    doc.owner == userId
  fetch: ['owner']

# Observers

@Schedules.find().observe
  changed: (newDoc, oldDoc) ->
    # The owner field has just been added
    if newDoc.owner and not oldDoc.owner
      user = newDoc.owner
      newSchedule = {}
      newSchedule[newDoc.semester] = newDoc._id
      Meteor.users.update user,
        $set:
          profile:
            schedules:
              newSchedule
  removed: (oldDoc) ->
    owner = Meteor.users.findOne oldDoc.owner
    changeSet = {}
    changeSet['profile.schedules.' + oldDoc.semester] = ''
    Meteor.users.update owner,
      $unset:
        changeSet

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

  # Converts all included sections to FullCalendar Event objects
  # @return [Event]
  toFCEvents: ->
    sections = @getSections().fetch()
    events = (section.toFCEvents() for section in sections)
    events = _.flatten events
    return events
