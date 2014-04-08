Meteor.publish 'courses', (courseFulls) ->
  if not _.isArray courseFulls
    courseFulls = [courseFulls]

  return [
    Courses.find
      courseFull:
        $in: courseFulls
    Sections.find
      courseFull:
        $in: courseFulls
  ]

Meteor.publish 'sections', (sectionFulls) ->
  if not Co.isArray sectionFulls
    sectionFulls = [sectionFulls]

  courseFulls =
    for sectionFull in sectionFulls
      Co.courseHelper.sectionFulltoCourseFull sectionFull

  return [
    Sections.find
      sectionFull:
        $in: sectionFulls
    Courses.find
      courseFull:
        $in: courseFulls
  ]

Meteor.publish 'schedules', ->
  return [
    Schedules.find owner: @userId
  ]
