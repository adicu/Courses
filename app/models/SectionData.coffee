mongoose = require 'mongoose'

env = process.env.NODE_ENV or 'development'
config = require('../config/config')(env)
Schema = mongoose.Schema

SectionDataSchema = new Schema
  CampusCode: String
  Course: String
  DepartmentCode: String
  Instructor1Name: String
  NumFixedUnits: String
  MaxSize: String
  MeetsOn: [String]
  SectionFull: String
  SchoolCode: String
  Term: String

  { collection: 'sectionsd' }

SectionData = mongoose.model 'SectionData', SectionDataSchema
