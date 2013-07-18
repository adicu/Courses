angular.module('Courses.controllers')
.controller 'scheduleCtrl', ($scope, Course, Calendar) ->
  calendar = new Calendar
  $scope.hours = Calendar.getHours()
  $scope.days = Calendar.getDays()
  $scope.semesters = Calendar.getValidSemesters()
  $scope.selectedSemester = $scope.semesters[0]
  $scope.searchResults = []
  $scope.courseCalendar = calendar.courseCalendar
  $scope.modalSection = {}
  calendar.fillFromURL($scope.selectedSemester)

  $scope.getTotalPoints = ->
    calendar.totalPoints()

  $scope.search = ->
    if not $scope.searchQuery or $scope.searchQuery.length == 0
      $scope.clearResults()
      return
    Course.search($scope.searchQuery, $scope.selectedSemester, calendar)
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
      console.log 'updating url'
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