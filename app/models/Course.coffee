mongoose = require 'mongoose'

env = process.env.NODE_ENV or 'development'
config = require('../config/config')(env)

Schema = mongoose.Schema
CourseData = mongoose.model 'CourseData'

CourseSchema = new Schema
  CourseFull: String
  _creator:
    type: Number
    ref: 'User'
  _data:
    type: Schema.Types.ObjectId
    ref: 'CourseData'
  members: [
    _user:
      type: Number
      ref: 'User'
    dateJoined:
      type: Date
      default: Date.now
  ]

# Load data from the Courses dump
CourseSchema.post 'init', (doc) ->
  if doc.CourseFull
    CourseData.findOne
      'CourseFull': doc.CourseFull,
      (err, courseData) ->
        if err
          throw err
        doc._data = courseData._id

Course = mongoose.model 'Course', CourseSchema
