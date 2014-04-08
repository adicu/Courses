@Schedules = new Meteor.Collection 'schedules',
  schema: new SimpleSchema
    addedCourses:
      type: [Object]
      optional: true
    'addedCourses.$.course':
      type: String
      label: 'CourseFull reference'
    addedSections:
      type: [addedSection]
      optional: true
    semester:
      type: Number
    createdAt:
      CollectionsShared.createdAt
    updatedAt:
      CollectionsShared.updatedAt
    owner:
      CollectionsShared.owner

addedCourse = new SimpleSchema
  course:
    # CourseFull reference
    type: String

addedSection = new SimpleSchema
  isSelected:
    type: Boolean
  section:
    # SectionFull reference
    type: String

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
  added: (doc) ->
    user = @userId
    return if not user
    newSchedule = {}
    newSchedule[doc.semester] = doc._id
    Meteor.users.update user._id,
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
    Meteor.subscribe 'courses', courseFull, ->
      course = Courses.findOne
        courseFull: courseFull

      if not course
        if callback
          callback new Error 'This course does not exist'
        return

      Schedules.update @_id,
        $push:
          addedCourses:
            course: courseFull

  # @return [Course]
  getCourses: ->
    courses = @getCourseFulls()
    return Courses.find
      courseFull:
        $in: courses

  # @return [Section]
  getSections: ->
    sections = @getSectionFulls()
    return Sections.find
      sectionFull:
        $in: sections

  # @return [Section]
  getSelectedSections: ->
    sections = @getSelectedSectionFulls()
    return Sections.find
      sectionFull:
        $in: sections

  # @return [String] courseFulls
  getCourseFulls: ->
    courses = _.pluck @addedCourses, 'course'

  # @return [String] sectionFulls
  getSectionFulls: ->
    sections = _.pluck @addedSections, 'section'

  # @return [String] sectionFulls
  getSelectedSectionFulls: ->
    sections = _.filter @addedSections, (addedSection) ->
      addedSection.isSelected
    sections = _.pluck sections, 'section'

  getTotalPoints: ->
    totalPoints = 0
    selectedSectionFulls = @getSelectedSectionFulls()
    selectedCourseFulls = _.map selectedSectionFulls, (item) ->
      Co.helpers.sectionFulltoCourseFull item
    for course in @getCourses
      if _.contains selectedCourseFulls, course.courseFull
        totalPoints += course.numFixedUnits / 10
    totalPoints
