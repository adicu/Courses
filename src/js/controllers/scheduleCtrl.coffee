angular.module('Courses.controllers')
.controller 'scheduleCtrl', (
  $scope,
  $rootScope,
  Course,
  Schedule,
) ->
  $scope.schedule = new Schedule

  $scope.isModalOpen = false
  $scope.modalSection = {}

  initURL = () ->
    $scope.schedule.fillFromURL $scope.selectedSemester
    @updateURL()

  $scope.getTotalPoints = () ->
    $scope.schedule.getTotalPoints()

  $scope.sectionSelected = (section, shouldUpdateURL = true) ->
    section.select()
    @updateURL() if shouldUpdateURL

  updateURL: () ->
    # TODO: implement
    return
    str = ''
    for key,section of sections
      if section
        str = str + section.data['CallNumber'] + ','
    if str and str.charAt(str.length - 1) == ','
      str = str.slice(0, -1)
    $location.hash ''
    $location.search('sections', str)

  # Course is selected, say from search
  # Course should now be added to the schedule.
  $scope.courseSelect = (course) ->
    Course.fetchByCourseFull(course.CourseFull).then (course) ->
      console.log 'Added course: ', course
      $scope.schedule.addCourse course
    , (error) ->
      throw error if error
