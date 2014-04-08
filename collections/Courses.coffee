@Courses = new Meteor.Collection 'courses',
  schema: new SimpleSchema
    courseFull:
      type: String
      label: 'ex. COMSS3203'
      index: 1
      unique: true
    description:
      type: String
    courseTitle:
      type: String
      label: 'ex. DISCRETE MATHEMATICS'
    departmentCode:
      type: String
      label: 'ex. COMS'
    points:
      type: Number
      label: 'ex. 30'
    createdAt:
      CollectionsShared.createdAt

# Adds additional options to a given elasticsearch request
# given a query string
buildRequest = (query, ejsRequest) ->
  ejsQuery = ejs.BoolQuery()
    .should(ejs.QueryStringQuery query)

  # Match full course (ie COMSW1004)
  if match = query.match /^([A-Z]{4})[A-Z]?(\d{1,4})/i
    department = match[1]
    courseNumber = match[2]
    courseSearch = department + courseNumber + '*'

    ejsQuery.should(ejs.FieldQuery 'Course', courseSearch)
      .boost(3.0)

  # Match department (ie COMS)
  else if match = query.match /^[a-zA-Z]{4}/i
    department = match[0]
    ejsQuery.should(ejs.FieldQuery 'DepartmentCode', department)
      .boost(1.5)

  ejsRequest.query(
    ejsQuery
  )
  ejsRequest

# Automatically performs the correct full text search for
# query, setting Session variable coursesSearchResults
@Courses.search = (query) ->
  ejs.client = new ejs.jQueryClient Co.constants.config.ES_API
  ejsRequest = ejs.Request()
    .indices('data')
    .types('courses')
  buildRequest(query, ejsRequest)
    .filter(
      ejs.TermFilter 'Term', Session.get 'currentSemester'
    )
    .doSearch()
    .then (data) ->
      if not (data and data.hits and data.hits.hits)
        handleError new Error 'Data not received'
        return
      hits = data.hits.hits
      hits = _.map hits, (hit) ->
        hit['_source']
      Session.set 'coursesSearchResults', hits
    , (error) ->
      handleError error

# Helpers
@Courses.helpers
  # @return [Sections]
  getSections: (options) ->
    Sections.find
      courseFull: @courseFull,
      options
