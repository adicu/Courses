courseHelper = require '../helpers/courseHelper'
mongoose = require 'mongoose'
Q = require 'q'

CourseData = mongoose.model 'CourseData'
SectionData = mongoose.model 'SectionData'

findOneCourse = Q.nbind CourseData.findOne, CourseData
findOneSection = Q.nbind SectionData.findOne, SectionData

exports.query = (req, res) ->
  console.log req.params

  req.assert('department').isAlpha()

  department = req.params.department
  CourseData.findByDepartment(department)
  .then (docs) ->
    res.jsonp data
