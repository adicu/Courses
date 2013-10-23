angular.module('Courses.directives')
.directive 'weekView', (
  CourseState,
) ->
  templateUrl: 'partials/directives/weekView.html'
  restrict: 'E'
  scope:
    schedule: '='

  controller: (
    $scope,
    $element,
    $attrs,
    $transclude,
    CourseState
  ) ->
    $scope.schedule.fillFromURL()

    $scope.CourseState = CourseState

    $scope.getDays = () ->
      $scope.schedule.getDays()
    $scope.getHours = () ->
      $scope.schedule.getHours()

    $scope.sectionsByDay = () ->
      $scope.schedule.sectionsByDay

    $scope.selectSection = (section) ->
      section.getParentCourse().state CourseState.VISIBLE
      section.select()
      $scope.schedule.update()

    $scope.removeSection = (section) ->
      section.select false
      $scope.schedule.update()
