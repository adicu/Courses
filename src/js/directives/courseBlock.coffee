angular.module('Courses.directives')
.directive 'courseBlock', () ->
  templateUrl: 'partials/directives/courseBlock.html'
  restrict: 'E'
  scope:
    schedule: '='
  
  
angular.module('Courses.controllers')
.controller 'popoverCtrl', (
  $scope
) ->
  	$scope.removeCourse = (course) ->
  		$scope.schedule.removeCourse course
  		
  	$scope.changeSections = (course) ->
  		$scope.schedule.removeCourse course
  		course.selectedSections = []
  		$scope.schedule.addCourse course
		