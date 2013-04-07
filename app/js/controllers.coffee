"use strict"

# Controllers 
rootCtrl = ($scope, Course, Calendar) ->
  calendar = new Calendar
  $scope.hours = Calendar.hours
  $scope.days = Calendar.days
  $scope.semesters = Calendar.getValidSemesters()
  $scope.selectedSemester = $scope.semesters[0]
  $scope.searchResults = []
  $scope.courseCalendar = calendar.courseCalendar

  $scope.search = ->
    if $scope.searchQuery.length == 0
      $scope.clearResults()
      return
    Course.search($scope.searchQuery, $scope.selectedSemester)
      .then (data) ->
        console.log data
        $scope.searchResults = data

  $scope.clearResults = ->
    $scope.searchResults = []

  $scope.courseSelect = (course) ->
    $scope.clearResults()
    return if calendar.courses[course.id]
    course.getSections().then (status) ->
      return if not status
      calendar.addCourse course

  $scope.removeCourse = (id) ->
    calendar.removeCourse id

  $scope.sectionSelect = (subsection) ->
    section = subsection.parent
    return if not section.parent.status
    calendar.sectionChosen section


#rootCtrl.$inject = []