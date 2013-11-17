angular.module('Courses.directives')
.directive 'courseBlock', () ->
  templateUrl: 'partials/directives/courseBlock.html'
  restrict: 'E'
  scope:
    schedule: '='
  controller: (
    $scope
    $location
  ) ->
    $scope.pageUrl = $location.absUrl()
    $scope.$on '$routeUpdate', () ->
      $scope.pageUrl = $location.absUrl()


angular.module('Courses.controllers')
.controller 'popoverCtrl', (
  $scope,
  $rootScope,
  $location
) ->

    $scope.removeCourse = (course) ->
      $scope.schedule.removeCourse course
      $scope.hide()

    $scope.changeSections = (course) ->
      $scope.schedule.removeCourse course
      for section in course.selectedSections
        section.selected = false
      course.selectedSections = []
      $scope.schedule.addCourse course
      $scope.hide()

    clickAway = (element) ->
      $(document).click (event) ->
        if $(event.target).parents.index element == -1
          $scope.hide()
