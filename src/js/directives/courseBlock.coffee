angular.module('Courses.directives')
.directive 'courseBlock', () ->
  templateUrl: 'partials/directives/courseBlock.html'
  restrict: 'E'
  scope:
    schedule: '='
  controller: (
    $scope,
    $location,
  ) ->
    $scope.pageUrl = $location.absUrl()
    $scope.$on '$routeUpdate', () ->
      $scope.pageUrl = $location.absUrl()
