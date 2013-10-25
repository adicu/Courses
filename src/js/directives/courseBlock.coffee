angular.module('Courses.directives')
.directive 'courseBlock', () ->
  templateUrl: 'partials/directives/courseBlock.html'
  restrict: 'E'
  scope:
    schedule: '='
  
  controller: ($scope, $timeout) ->
  	
  	$scope.removeCourse = (course) ->
  		$scope["closePopover" + course.id] = true
  		
  		remove = () ->
  			$scope.schedule.removeCourse course
  			$scope["closePopover" + course.id].remove
  		
  		$timeout remove, 400
  	