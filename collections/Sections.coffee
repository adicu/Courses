@Sections = new Meteor.Collection 'sections',
  schema: new SimpleSchema
    courseFull:
      type: String
      label: 'ex. COMSS3203'
      index: 1
    sectionFull:
      type: String
      label: 'ex. 20133COMS3203S001'
      index: 1
      unique: true
    callNumber:
      type: Number
    meetsOn:
      type: [String]
    building:
      type: [String]
    startTime:
      type: [String]
    endTime:
      type: [String]
    term:
      type: String
    instructors:
      type: String
    numEnrolled:
      type: Number
    room:
      type: [String]
    createdAt:
      CollectionsShared.createdAt
