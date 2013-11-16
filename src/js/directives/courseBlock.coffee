angular.module('Courses.directives')
.directive 'courseBlock', () ->
  templateUrl: 'partials/directives/courseBlock.html'
  restrict: 'E'
  scope:
    schedule: '='


angular.module('Courses.controllers')
.controller 'popoverCtrl', (
  $scope,
  $rootScope
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

    $scope.$on 'popover-shown', (ev) ->
      $(document).on 'click.hidepopover', (event) ->
        if not $(event.target).parents().filter('.courseBlock').length
          # Click outside the popover
          $scope.hide()

    $scope.$on 'popover-hide', (ev) ->
      $(document).off 'click.hidepopover'
