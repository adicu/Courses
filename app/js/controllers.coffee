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
    Course.search($scope.searchQuery, $scope.selectedSemester, '10', '1')
      .then (data) ->
        console.log data
        $scope.searchResults = data

  $scope.clearResults = ->
    $scope.searchResults = []

  $scope.courseSelect = (course) ->
    $scope.clearResults()
    # course.getInfo()
    #   .then () ->
    calendar.addCourse course

  $scope.removeCourse = (section) ->
    calendar.removeCourse section


#rootCtrl.$inject = []