angular.module('Courses.models')
.factory 'Course', (
  $http,
  $q,
  $rootScope,
  CONFIG,
  Section,
) ->
  class Course
    constructor: (@data, term) ->
      @sections = []
      @selectedSections = []

      @id = @data.Course
      @idFull = @data.CourseFull
      @points = @data.NumFixedUnits / 10.0
      @title = @data.CourseTitle

      @createSections(term)

    # Create sections from data JSON
    # @param term to filter on
    createSections: (term) ->
      for sectionData in @data.Sections
        if term
          if sectionData.Term == term
            section = new Section sectionData, @
        else
          section = new Section sectionData, @
        @addSection section

    addSection: (section) ->
      @sections.push section
      if section.isSelected()
        @selectedSections.push section

    # @return {Section} Returns section on success.
    selectSection: (section) ->
      return section if section.isSelected()
      if _.findWhere(@selectedSections, callNumber: section.callNumber)
        # This section is already selected.
        # TODO: Error handling.
        return false
      else
        @selectedSections.push section
      section

    # @return {Section} Returns section for call on success.
    selectSectionByCall: (callNumber) ->
      if _.findWhere(@selectedSections, callNumber: callNumber)
        # This section is already selected.
        # TODO: Error handling.
        return false
      else
        section = _.findWhere(@sections, callNumber: callNumber)
        @selectedSections.push section
      section

    # Returns selected sections for a given day.
    # @param number day int representing which day
    #   is wanted. 0 -> M, 1 -> T, etc.
    getSectionsByDay: (day) ->
      sectionsByDay =
        for section in @selectedSections
          if section.isSelectedForDay(day)
            section
          else
            continue

    isSelected: () ->
      new Boolean @selectedSections.length

    # @return [Promise<Course>] | string Array of courses
    #   or string representing type of search.
    @search: (query, term = $rootScope.selectedSemester) ->
      d = $q.defer()
      if query.match /^\d{5}$/
        # Query is a section call number.
        callnum = parseInt query, 10
        Course.queryBySectionCall(callnum).then (course) ->
          d.resolve 'callnum'
        , (error) ->
          d.reject error
      else
        Course.query(query, term).then (courseData) ->
          d.resolve courseData
        , (error) ->
          d.reject error
      d.promise

    # Full text search over courses
    # @return [{}] representing Course data
    #   Not Courses because ES doesn't give full information
    @query: (query, term = $rootScope.selectedSemester) ->
      d = $q.defer()
      $http
        method: 'JSONP'
        url: "#{CONFIG.DATA_API}search"
        params:
          jsonp: 'JSON_CALLBACK'
          api_token: CONFIG.API_TOKEN
          q: query
          term: term
      .success (data, status, headers, config) ->
        d.resolve data.data
      .error (data, status) ->
        d.reject new Error 'Query failed with status ' + status
      d.promise

    # Search by the section call number
    # @return {Promise<Section>} Section for given callNumber.
    @queryBySectionCall: (
      callNumber,
      term = $rootScope.selectedSemester,
      filters
    ) ->
      d = $q.defer()
      $http
        method: 'JSONP'
        url: "#{CONFIG.COURSES_API}sections/#{callNumber}"
        params:
          jsonp: 'JSON_CALLBACK'
          call_number: callNumber
          term: term
          withcourse: filters.withcourse or true
      .success (data, status, headers, config) =>
        course = new Course data
        section = course.selectSectionByCall callNumber
        d.resolve section
      .error (data, status) ->
        d.reject new Error 'getCourseFromCall failed with status ' + status
      d.promise

    # @return [Promise<Course>] given its corresponding CourseFull info.
    # ex. COMSW1004
    @fetchByCourseFull: (courseFull, term = $rootScope.selectedSemester) ->
      d = $q.defer()
      if not courseFull
        throw new Error 'courseFull required'
      $http
        method: 'JSONP'
        url: "#{CONFIG.DATA_API}courses"
        params:
          jsonp: 'JSON_CALLBACK'
          api_token: CONFIG.API_TOKEN
          course_full: courseFull
      .success (data) ->
        if !(data.data and data.data.length > 0)
          d.reject new Error 'No matching course for courseFull: ' + courseFull
        course = new Course data.data[0], term
        console.log course
        d.resolve course
      .error (data, status) ->
        d.reject new Error 'fetchByCourseFull failed with status ' + status
      d.promise
