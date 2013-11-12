angular.module('Courses.models')
.factory 'Course', (
  $http,
  $q,
  $rootScope,
  CONFIG,
  CourseState,
  Section,
) ->
  class Course
    constructor: (@data, term) ->
      @sections = []
      @selectedSections = []

      @id = @data.Course
      @IDFull = @data.CourseFull
      @points = @data.NumFixedUnits / 10.0
      @title = @data.CourseTitle
      @description = @data.Description
      @_state = CourseState.VISIBLE

      @createSections(term)


    # Create sections from data JSON
    # @param term to filter on
    createSections: (term) ->
      for sectionData in @data.Sections
        if term
          if sectionData.Term == term
            section = new Section sectionData, @
          else
            continue
        else
          section = new Section sectionData, @
        @addSection section

    addSection: (section) ->
      @sections.push section
      if section.isSelected()
        @selectedSections.push section

    # Select or deselect sections
    # @return {Section} Returns section on success.
    selectSection: (section, state = true) ->
      section.selected = state
      if state
        if _.findWhere(@selectedSections, callNumber: section.callNumber)
          # Section is already selected
          return section
        else
          @selectedSections.push section
      else
        @selectedSections = _.filter @selectedSections, (x) ->
          x.callNumber isnt section.callNumber

    # @return {Section} Returns section for call on success.
    selectSectionByCall: (callNumber) ->
      if _.findWhere(@selectedSections, callNumber: callNumber)
        # This section is already selected.
        # TODO: Error handling.
        return false
      else
        section = _.findWhere(@sections, callNumber: parseInt callNumber)
        section.selected = true
        @selectedSections.push section
      section

    # Returns selected sections for a given day.
    # @param number day int representing which day
    #   is wanted. 0 -> M, 1 -> T, etc.
    # @param  filterSelected to filter to only selected sections
    getSectionsByDay: (day, filterSelected = true) ->
      if filterSelected
        sectionsByDay = _.filter @selectedSections, (section) ->
          section.isOnDay(day)
      else
        sectionsByDay = _.filter @sections, (section) ->
          section.isOnDay(day)
      sectionsByDay

    isSelected: () ->
      new Boolean @selectedSections.length

    # Checks various things to see if this course is valid
    isValid: () ->
      selfCheck = @IDFull? and @title? and @points?
      childrenCheck = true
      for section in @sections
        childrenCheck = childrenCheck and section.isValid()
      selfCheck and childrenCheck

    # Setter and getter for state
    state: (newState) ->
      if newState
        @_state = newState
      @_state

    # @return [Promise<Course>] | string Array of courses
    #   or string representing type of search.
    @search: (query, term = $rootScope.selectedSemester) ->
      d = $q.defer()
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
    # @return Promise<Course> Course for given callNumber with
    #   section selected.
    @queryBySectionCall: (
      callNumber,
      term = $rootScope.selectedSemester
    ) ->
      d = $q.defer()
      $http
        method: 'JSONP'
        url: "#{CONFIG.DATA_API}sections"
        params:
          jsonp: 'JSON_CALLBACK'
          api_token: CONFIG.API_TOKEN
          call_number: callNumber
          term: term

      .success (data, status, headers, config) =>
        if not data['data']
          d.reject new Error "No such section #{callNumber}"
        courseID = data['data'][0].Course

        Course.fetchByCourseID(courseID).then (course) ->
          course.selectSectionByCall callNumber
          d.resolve course
        , (error) ->
          d.reject error

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
          return
        course = new Course data.data[0], term
        d.resolve course
      .error (data, status) ->
        d.reject new Error 'fetchByCourseFull failed with status ' + status
      d.promise

    @fetchByCourseID: (courseID, term = $rootScope.selectedSemester) ->
      d = $q.defer()
      if not courseID
        throw new Error 'courseID required'
      $http
        method: 'JSONP'
        url: "#{CONFIG.DATA_API}courses"
        params:
          jsonp: 'JSON_CALLBACK'
          api_token: CONFIG.API_TOKEN
          courseid: courseID
      .success (data) ->
        if !(data.data and data.data.length > 0)
          d.reject new Error 'No matching course for courseID: ' + courseID
          return
        course = new Course data.data[0], term
        d.resolve course
      .error (data, status) ->
        d.reject new Error 'fetchByCourseFull failed with status ' + status
      d.promise
