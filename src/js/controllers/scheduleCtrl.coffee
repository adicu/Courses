angular.module('Courses.controllers')
.controller 'scheduleCtrl', (
  $scope,
  Calendar,
  Course,
  CourseHelper,
) ->
  calendar = $scope.calendar = new Calendar
  $scope.semesters = CourseHelper.getValidSemesters()
  $scope.selectedSemester = $rootScope.selectedSemester =
    $scope.semesters[0]

  $scope.isModalOpen = false
  $scope.modalSection = {}

  calendar.fillFromURL($scope.selectedSemester)

  $scope.getTotalPoints = () ->
    calendar.getTotalPoints()
