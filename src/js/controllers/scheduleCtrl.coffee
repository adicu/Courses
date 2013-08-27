angular.module('Courses.controllers')
.controller 'scheduleCtrl', (
  $scope,
  Calendar,
  Course,
  CourseHelper,
) ->
  calendar = new Calendar
  $scope.hours = Calendar.getHours()
  $scope.days = Calendar.getDays()
  $scope.semesters = CourseHelper.getValidSemesters()
  $scope.selectedSemester = $rootScope.selectedSemester =
    $scope.semesters[0]
  $scope.searchResults = []
  $scope.modalSection = {}
  calendar.fillFromURL($scope.selectedSemester)

  $scope.getTotalPoints = ->
    calendar.totalPoints()

  $scope.search = ->
    query = $scope.searchQuery
    if not query or query.length == 0
      $scope.clearResults()
      return
    Calendar.search(query, $scope.selectedSemester)
      .then (data) ->
        if data == 'callnum'
          $scope.clearResults()
        else
          $scope.searchResults = data

  $scope.clearResults = ->
    $scope.searchResults = []
    $scope.searchQuery = ""

  $scope.courseSelect = (course) ->
    $scope.clearResults()
    course.fillData().then (status) ->
      return if not status
      console.log course
      calendar.addCourse course

  $scope.removeCourse = (id) ->
    closeModal()
    calendar.removeCourse id
    calendar.updateURL()

  $scope.sectionSelect = (subsection) ->
    section = subsection.parent
    if section.parent.status
      calendar.sectionChosen section
      calendar.updateURL()
    else
      openModal()
      $scope.modalSection = section

  closeModal = ->
    $scope.$broadcast 'modalStateChange', 'close'
  openModal = ->
    $scope.$broadcast 'modalStateChange', 'open'

  $scope.changeSections = (section) ->
    closeModal()
    course = section.parent
    calendar.changeSections course