mongoose = require 'mongoose'

CourseData = mongoose.model 'CourseData'
SectionData = mongoose.model 'SectionData'

exports.query = (req, res) ->
  console.log req.query
  CourseFull = req.query.coursefull
  term = req.query.term
  if not (CourseFull and term)
    res.send 400, 'Invalid query params'
    return
  CourseData.findOne
    'CourseFull': CourseFull
    (err, courseData) ->
      throw err if err
      CourseData.lookupSections courseData, (data) ->
        res.jsonp data
