angular.module('Courses.services')
.factory 'CoursesLoader', (
  $http,
  $rootScope,
  $q,
  elasticSearch,
  Course
) ->
  class CoursesLoader
    @api_url = 'http://data.adicu.com/courses/v2/'
    @api_token = '51ffc99d0b18dc0002859b8d'

    @loadCourse: (course_id) ->
      d = $q.defer()
      course = CoursesLoader.initCourse(course_id).then (course) ->
        if course
          CoursesLoader.getCourseData(course)
        else
          d.reject('Course loading error.')
      d.promise

    @initCourse: (course_id) ->
      d = $q.defer()
      $http
        method: 'JSONP'
        url: Course.api_url + 'courses'
        params:
          course: course_id
          term: $rootScope.selectedSemester
          jsonp: 'JSON_CALLBACK'
          api_token: CoursesLoader.api_token
      .success (datarecv, status, headers, config) =>
        d.resolve false if not datarecv.data
        ejs_data = CoursesLoader.convertAPItoEJS datarecv.data[0]

        course = new Course course_id, $rootScope.selectedSemester,
          ejs_data

        @getSections().then ->
          d.resolve true
      .error (data, status) ->
        d.resolve false
      d.promise

    @getCourseData: (course) ->
      return if course.sections and course.sections.length >= 1
      d = $q.defer()
      course.sections = []

      for sec in course.data.sections
        if sec.Term == course.semester
          s = new Section sec.CallNumber, @semester, sec, course
          @sections.push s

      promises = []
      for sec in @sections
        promises.push sec.fillData()

      $q.all(promises).then () =>
        @sections = @sections.filter (el) ->
          for subsec in el.subsections
            if subsec.length > 0
              return true
          return false
        d.resolve true
      d.promise

    @convertAPItoEJS: (coursedata) ->
      for k,v of coursedata
        coursedata[CoursesLoader.CUITCaseToUnderscore k] = v
      return coursedata

    @CUITCaseToUnderscore: (cuitcase) ->
      cuitcase = cuitcase.charAt(0).toLowerCase() + cuitcase.slice(1)
      return cuitcase.replace /([A-Z])/g, ($1) ->
        return "" + $1.toLowerCase()
