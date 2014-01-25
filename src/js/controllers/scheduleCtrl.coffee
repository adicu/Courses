angular.module('Courses.controllers')
.controller 'scheduleCtrl', (
  $scope,
  $rootScope,
  Course,
  Schedule,
  CourseHelper,
) ->
  $scope.schedule = new Schedule
  $scope.schedule.initFromURL()
  $scope.schedule.shouldUpdateURL = true

  $scope.semesters = ['20141', '20133']

  $scope.getTotalPoints = () ->
    $scope.schedule.getTotalPoints()

  $scope.sectionSelected = (section) ->
    section.select()

  # Course is selected, say from search
  # Course should now be added to the schedule.
  $scope.courseSelect = (course) ->
    Course.fetchByCourseFull(course.CourseFull).then (course) ->
      $scope.schedule.addCourse(course)
    , (error) ->
      throw error if error

  # Section has been clicked, popup should be triggered.
  $scope.sectionClicked = (section) ->
    $scope.$broadcast 'sectionClicked', section
