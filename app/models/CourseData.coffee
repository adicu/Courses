mongoose = require 'mongoose'

env = process.env.NODE_ENV or 'development'
config = require('../config/config')(env)
Schema = mongoose.Schema
SectionData = mongoose.model 'SectionData'

CourseDataSchema = new Schema
  Course: String
  CourseFull: String
  CourseSubtitle: String
  CourseTitle: String
  DepartmentCode: String
  NumFixedUnits: String
  SchoolCode: String

  _sections: [
    type: Schema.Types.ObjectId
    ref: 'SectionData'
  ]

  { collection: 'coursesd' }

# Lazy lookup sections
CourseDataSchema.statics.lookupSections = (courseData, callback) ->
  callback() if not courseData.CourseFull
  courseData = courseData.toObject()
  SectionData.find
    'CourseFull': courseData.CourseFull
    (err, sections) ->
      throw err if err
      courseData.sections = courseData.sections or []
      for section in sections
        courseData.sections.push section
      callback(courseData)


CourseData = mongoose.model 'CourseData', CourseDataSchema
