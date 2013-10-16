angular.module('Courses.controllers')
.controller 'scheduleCtrl', (
  $scope,
  $rootScope,
  CalendarView,
  Course,
  CourseHelper,
) ->
  calendar = $scope.calendar = new CalendarView
  $scope.semesters = CourseHelper.getValidSemesters()
  $scope.selectedSemester = $rootScope.selectedSemester =
    $scope.semesters[0]

  $scope.isModalOpen = false
  $scope.modalSection = {}

  calendar.fillFromURL($scope.selectedSemester)

  $scope.getTotalPoints = () ->
    calendar.getTotalPoints()
