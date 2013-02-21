"use strict"

# Controllers 
rootCtrl = ($scope, Semester) ->
  $scope.hours = [8..23]
  $scope.days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
  $scope.semesters = Semester.getValidSemesters()
  $scope.selectedSemester = $scope.semesters[0]

#rootCtrl.$inject = []