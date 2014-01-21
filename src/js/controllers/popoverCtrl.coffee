angular.module('Courses.controllers')
.controller 'popoverCtrl', (
  $scope,
  $rootScope,
  $timeout,
  Colors
) ->
  popoverShown = false
  course = $scope.$parent.course
  $scope.Colors = Colors
  $scope.displayName = if course.displayName == course.getDefaultDisplayName() then '' else course.displayName

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

  $scope.colorChanged = (color) ->
    $scope.schedule.update()

  $scope.$on 'sectionClicked', (event, section) ->
    if section.id is $scope.course.id and not popoverShown
      $timeout () ->
        $scope.show()

  $scope.$watch 'displayName', () ->
    course.displayName = if $scope.displayName == '' then course.getDefaultDisplayName() else $scope.displayName
    $scope.schedule.update()

  # Handle clicks outside of the popover so the popover closes
  $scope.$on 'popover-shown', (ev) ->
    popoverShown = true
    $(document).on 'click.hidepopover', (event) ->
      if not $(event.target).parents().filter('.courseBlock').length
        # Click outside the popover
        $scope.hide()

  $scope.$on 'popover-hide', (ev) ->
    popoverShown = false
    $(document).off 'click.hidepopover'
