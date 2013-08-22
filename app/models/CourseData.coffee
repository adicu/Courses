mongoose = require 'mongoose'
Q = require 'q'

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
CourseDataSchema.statics.lookupSections = (courseData) ->
  d = Q.defer()
  d.reject 'No course ref.' if not courseData.CourseFull
  courseData = courseData.toObject()
  SectionData.find
    'CourseFull': courseData.CourseFull
    (err, sections) ->
      d.reject err if err
      courseData.sections = courseData.sections or []
      for section in sections
        courseData.sections.push section
      d.resolve courseData
  d.promise


CourseData = mongoose.model 'CourseData', CourseDataSchema
