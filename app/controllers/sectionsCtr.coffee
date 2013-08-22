courseHelper = require '../helpers/courseHelper'
mongoose = require 'mongoose'
Q = require 'q'

CourseData = mongoose.model 'CourseData'
SectionData = mongoose.model 'SectionData'

findOneCourse = Q.nbind CourseData.findOne, CourseData
findOneSection = Q.nbind SectionData.findOne, SectionData

baseQuery = (callNumber) ->
  d = Q.defer()
  findOneSection('CallNumber': callNumber)
  .then (sectionDoc) ->
    d.reject 'No matching section found' if not sectionDoc
    d.resolve sectionDoc
  d.promise


exports.query = (req, res) ->
  console.log req.params

  callNumber = req.params.callNumber
  if req.query.withcourse
    courseHelper.courseBySectionCall(callNumber)
    .done (data) ->
      res.jsonp data
  else
    baseQuery(callNumber)
    .done (data) ->
      res.jsonp data
