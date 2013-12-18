angular.module('Courses.models')
.factory 'Course', (
  $http,
  $q,
  $rootScope,
  CONFIG,
  CourseState,
  elasticSearch,
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

    # Checks to see if this course overlaps with the other course
    isOverlapping: (other) ->
      return false if not other
      for thisSection in @selectedSections
        for otherSection in other.selectedSections
          return true if thisSection.isOverlapping otherSection
      return false

    # @return [Promise<Course>] | string Array of courses
    #   or string representing type of search.
    @search: (query, term = $rootScope.selectedSemester) ->
      d = $q.defer()
      Course.query(query, term).then (courseData) ->
        d.resolve courseData
      , (error) ->
        d.reject error
      d.promise

    # Dynamically builds an ElasticSearch query
    # by modifying ejsRequest
    @buildQuery: (queryString, ejsRequest) ->
      ejs = elasticSearch.ejs
      ejsQuery = ejs.BoolQuery()
        .minimumNumberShouldMatch(1)

      globalCoreString = "AFASC1001 OR ANTHV1008 OR ANTHV1130 OR ANTHV2010 OR ANTHV2013 OR ANTHV2014 OR ANTHV2020 OR ANTHV2027 OR ANTHV2035 OR ANTHV2100 OR ANTHV3300 OR ANTHV3465 OR ANTHV3525 OR ANTHV3821 OR ANTHV3892 OR ANTHV3933 OR ANTHV3947 OR ANHSW4001 OR ANTHG4065 OR AHISV3201 OR AHISW3208 OR AHUMV3340 OR AHUMV3342 OR AHISG4085 OR AFCVC1020 OR LACVC1020 OR CSERW1010 OR CSERW1600 OR CSERW1601 OR CSERW3250 OR CSERW3510 OR CSERW3922 OR CSERW3926 OR CSERW3928 OR CSERW3961 OR INSMW3920 OR INSMW3921 OR INSMC3940 OR INSMW3950 OR CPLSW3333 OR CPLSW3454 OR CPLSW3620 OR CPLSW3945 OR CPLSW3955 OR CPLSW3956 OR CLGMV3920 OR ASCEV2002 OR ASCEV2359 OR ASCEV2361 OR ASCEV2363 OR ASCEV2365 OR AHUMV3400 OR AHUMV3830 OR EAASV3927 OR EAASG4160 OR ECONW4325 OR CLENW4200 OR HISTW3618 OR HISTW3657 OR HISTW3660 OR HISTV3661 OR HISTW3665 OR HISTW3701 OR HISTW3719 OR HISTW3764 OR HISTW3772 OR HISTW3800 OR HISTW3803 OR HISTW3810 OR HISTW3811 OR HSEAW3898 OR HISTW3943 OR HISTW4404 OR HISTW4779 OR SPANW3349 OR SPANW3350 OR SPANW3490 OR SPANW3491 OR PORTW3350 OR ASCMV2001 OR ASCMV2003 OR ASCMV2008 OR ASCMV2357 OR MDESW3000 OR MDESW3445 OR CLMEW3032 OR AHUMV3399 OR CLMEW4031 OR MDESG4052 OR CLMEG4241 OR CLMEG4261 OR MDESG4326 OR MUSIV2020 OR AHMMV3320 OR AHMMV3321 OR MUSIW4430 OR RELIV2008 OR RELIV2205 OR RELIV2305 OR RELIV2405 OR RELIV2645 OR SLCLW3001 OR CLRSW4190 OR SOCIW3324"

      goldNuggetString = "\"Shapiro, Jill\" OR \"Pazzaglini, Peter\" OR \"Rand, Archie\" OR \"Garton, Bradford\" OR \"Zetzel, James\" OR \"Vu-Daniel, Tomas\" OR \"Dames, Nicholas\" OR \"Milnor, Kristina\" OR \"Torrey, Kenneth\" OR \"Weston, Robert\" OR \"Katznelson, Ira\" OR \"Ziegler, Garrett\" OR \"Catterson, Lynn\" OR \"Bauman, Rebecca\" OR \"Legassie, Shayne\" OR \"Pouncey, Peter\" OR \"Williams, Gareth\" OR \"Olson, Kristina\" OR \"Miller, Robert\" OR \"Ruffini, Giovanni\" OR \"Beck, Karin\" OR \"Padilla, George\" OR \"Spencer, Gordon\" OR \"Valencia, Maria del Pilar\" OR \"Park, Peter\" OR \"Muller, Jill\" OR \"Deodatis, George\" OR \"White, Jennifer\" OR \"Murphy, Kevin\" OR \"Servedio, Rocco\" OR \"Hamilton, Saskia\" OR \"Negron-Muntaner, Frances\" OR \"Thomas, Colleen\" OR \"Ziolkowski, Saskia\" OR \"Lependorf, Jeffrey\" OR \"Hone, James\" OR \"Sharpe, Leslie\" OR \"Stein, Robert\" OR \"Pedersen, Susan\" OR \"Hamer, Hendrik\" OR \"Hiles, Karen\" OR \"Phillips, Sarah\" OR \"Amann, Elizabeth\" OR \"Gray, Erik\" OR \"Gibney, Brian\" OR \"Adil, Azfar\" OR \"Gurna, Elia\" OR \"Shapiro, Robert\" OR \"Martin, Severine\" OR \"Smith, Molly\" OR \"Vallancourt, David\" OR \"Alden, Jenna\" OR \"Papageorgiou, Anargyros\" OR \"Youell-Fingleton, Amber\" OR \"Amir Arjomand, Ramin\" OR \"Dohrn, Zayd\" OR \"Griffin, Farah\" OR \"Nusbaum, Juliet\" OR \"Vaughan, Diane\" OR \"Stillman, Jamy\" OR \"Pizzigoni, Caterina\" OR \"Nouhi, Youssef\" OR \"Kasdorf, Katherine\" OR \"Lilla, Mark\" OR \"Snyder, Scott B.\" OR \"Guy, Gary Michael\" OR \"Russell, Karen\" OR \"Tadiar, Neferti\" OR \"Benson, Amy\" OR \"Charles, Collomia\" OR \"Petrovic, Ana\" OR \"O'Connell, David\" OR \"Callahan, Daniel\" OR \"Buchan, Mark\" OR \"Snider, Justin\" OR \"Ahsan, Sonia\" OR \"Rosales-Varo, Francisco\" OR \"Absi, Ouijdane\" OR \"Webster, Anthony\" OR \"Watson, Mark\" OR \"Edwards, Brent\" OR \"Worthen, William\" OR \"Wang, Xiaodan\" OR \"Monroy, Liza\" OR \"Mendelson, Cheryl\" OR \"Marange, Celine\" OR \"Williams, Jon\" OR \"Bentancor, Orlando\" OR \"Ruiz-Campillo, Jose\" OR \"Shaw, Beau\" OR \"Kittay, David\" OR \"Hayman, Emily\" OR \"Johnson, Eleanor\" OR \"Gamber, John\" OR \"Conrad, Jessamyn\" OR \"Hughes, Ivana\" OR \"Llopis-Garcia, Reyes\" OR \"Williams, Catherine\" OR \"Mendelsohn, Susan\" OR \"Rodney, Mariel\" OR \"Baics, Gergely\" OR \"Kreitman, Rina\" OR \"Nail, Ashley\" OR \"Gutkin, David\" OR \"Engel, Nicholas\" OR \"Huback, Ana Paula\" OR \"Fucci, Robert\" OR \"Aufrichtig, Michael\" OR \"Howley, Joseph\""
      comsAITrackString = "COMSW4701 OR COMSW4705 OR COMSW4706 OR COMSW4731 OR COMSW4733 OR COMSW4771 OR COMSW4165 OR COMSW4252 OR COMSW4721 OR COMSW4731 OR COMSW4771 OR COMSW4772 OR COMSW4995 OR COMSW4996 OR COMSW6735 OR COMSW6998 OR COMSW6999 OR COMSW3902 OR COMSW3998 OR COMSW4901 OR COMSW6901 OR COMSW4111 OR COMSW4160 OR COMSW4170 OR COMSW4999"

      if (queryString.search /globalcore/) > -1
        ejsQuery.must(ejs.FieldQuery 'CourseFull', globalCoreString)
        queryString = queryString.replace /globalcore/, ""
        if queryString.trim().length == 0
            queryString = "*"

      if (queryString.search /goldnugget/) > -1
        ejsQuery.must(ejs.FieldQuery 'Instructor', goldNuggetString)
        queryString = queryString.replace /goldnugget/, ""
        if queryString.trim().length == 0
            queryString = "*"
      
      if (queryString.search /comstrackai/) > -1
        ejsQuery.must(ejs.FieldQuery 'CourseFull', comsAITrackString)
        queryString = queryString.replace /comstrackai/, ""
        if queryString.trim().length == 0
            queryString = "*"


      if (queryString.search /professorsearch/) > -1
        index = queryString.search /professorsearch/
        queryString = queryString.replace /professorsearch/, ""
        professorString = queryString.substring(index)
        queryString = queryString.substring(0, index)
        ejsQuery.must(ejs.FieldQuery 'Instructor', professorString)
        if queryString.trim().length == 0
            queryString = "*"
      
      if (queryString.search /departmentsearch/) > -1
        index = queryString.search /departmentsearch/
        queryString = queryString.replace /departmentsearch/, ""
        departmentString = queryString.substring(index)
        queryString = queryString.substring(0, index)
        ejsQuery.must(ejs.FieldQuery 'DepartmentCode', departmentString)
        if queryString.trim().length == 0
            queryString = "*"
 
      ejsQuery.should(ejs.QueryStringQuery queryString)
      
      # Match full course (ie COMSW1004)
      if match = queryString.match /^([A-Z]{4})[A-Z]?(\d{1,4})/i
        department = match[1]
        courseNumber = match[2]
        courseSearch = department + courseNumber + '*'

        ejsQuery.should(ejs.FieldQuery 'Course', courseSearch)
          .boost(3.0)

      # Match department (ie COMS)
      else if match = queryString.match /^[a-zA-Z]{4}/i
        department = match[0]
        ejsQuery.should(ejs.FieldQuery 'DepartmentCode', department)
          .boost(1.5)

      ejsRequest.query(
        ejsQuery
      )

    # Full text search over courses
    # @return [{}] representing Course data
    #   Not Courses because ES doesn't give full information
    @query: (query, term = $rootScope.selectedSemester) ->
      d = $q.defer()
      ejsRequest = elasticSearch.getCourseRequest()
      Course.buildQuery query, ejsRequest
      ejsRequest.filter(
        ejs.TermFilter 'Term', term
      )
      .doSearch()
      .then (data) ->
        if not (data and data.hits and data.hits.hits)
          d.reject new Error 'Data not received'
          return
        hits = data.hits.hits
        hits = _.map hits, (hit) ->
          hit['_source']
        d.resolve hits
      , (error) ->
        d.reject error
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
