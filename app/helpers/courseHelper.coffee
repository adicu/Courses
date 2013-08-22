mongoose = require 'mongoose'
Q = require 'q'

CourseData = mongoose.model 'CourseData'
SectionData = mongoose.model 'SectionData'

findOneCourse = Q.nbind CourseData.findOne, CourseData
findOneSection = Q.nbind SectionData.findOne, SectionData

exports.courseBySectionCall = (callNumber) ->
  d = Q.defer()
  findOneSection('CallNumber': callNumber)
  .then (sectionDoc) ->
    d.reject 'No matching section found' if not sectionDoc
    findOneCourse('Course': sectionDoc.Course)
    .then (courseDoc) ->
      d.reject 'No course found for section' if not courseDoc
      CourseData.lookupSections(courseDoc)
      .then (courseWithSections) ->
        d.resolve courseWithSections
  d.promise


exports.findCourseAndGetSections = (courseID) ->
  d = Q.defer()
  findOneCourse('Course': courseID)
  .then (courseDoc) ->
    d.reject 'No matching course found' if not courseDoc
    CourseData.lookupSections(courseDoc)
    .then (courseWithSections) ->
      d.resolve courseWithSections
  d.promise
