mongoose = require 'mongoose'
Q = require 'q'

CourseData = mongoose.model 'CourseData'
SectionData = mongoose.model 'SectionData'

cFindOne = Q.nbind CourseData.findOne, CourseData
sFindOne = Q.nbind SectionData.findOne, SectionData

exports.courseBySectionCall = (callNumber) ->
  d = Q.defer()
  sFindOne('CallNumber': callNumber)
  .then (sectionDoc) ->
    cFindOne('Course': sectionDoc.Course)
    .then (courseDoc) ->
      CourseData.lookupSections(courseDoc)
      .then (courseWithSections) ->
        d.resolve courseWithSections
  d.promise


exports.findCourseAndGetSections = (courseID) ->
  d = Q.defer()
  cFindOne('Course': courseID)
  .then (courseDoc) ->
    CourseData.lookupSections(courseDoc)
    .then (courseWithSections) ->
      d.resolve courseWithSections
  d.promise
