angular.module('Courses.directives')
.directive 'weekView', (
  CourseState,
) ->
  templateUrl: 'partials/directives/weekView.html'
  restrict: 'E'
  scope:
    schedule: '='
    onsectionclicked: '&'

  controller: (
    $scope,
    $rootScope,
    $element,
    $attrs,
    $transclude
  ) ->
    $scope.CourseState = CourseState

    $scope.getDays = () ->
      $scope.schedule.getDays()
    $scope.getHours = () ->
      $scope.schedule.getHours()

    $scope.sectionsByDay = () ->
      $scope.schedule.sectionsByDay

    # Section of a course has been clicked
    $scope.selectSection = (section) ->
      # User needs to select from multiple sections of a course
      if section.getParentCourse().state() is
            CourseState.EXCLUSIVE_VISIBLE
        section.getParentCourse().state CourseState.VISIBLE
        section.select()
        $scope.schedule.update()
      # Popup should open
      else
        $scope.onsectionclicked section: section

    $scope.removeSection = (section) ->
      section.select false
      $scope.schedule.update()
