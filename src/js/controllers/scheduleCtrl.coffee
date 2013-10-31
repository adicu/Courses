angular.module('Courses.controllers')
.controller 'scheduleCtrl', (
  $scope,
  $cookies,
  $rootScope,
  $FB,
  $location,
  Course,
  Schedule,
  CourseHelper
) ->
  $scope.schedule = new Schedule

  $scope.isModalOpen = false
  $scope.modalSection = {}

  $scope.semesters = ['20141', '20133']

  initURL = () ->
    $cookies.sectionsString = ""
    $location.search('sections', '')
    return # TODO: SAVING IS DISABLED

    # if $cookies.sectionsString == undefined
    #  $cookies.sectionsString = ""

    # if ($location.search()).sections == undefined or ($location.search()).sections.length == 0
    #   console.log $cookies.sectionsString
    #   $location.search('sections', $cookies.sectionsString)
    # else
    #   console.log ($location.search()).sections

    # $scope.schedule.fillFromURL $rootScope.selectedSemester

  initURL()

  updateURL = () ->
    return
    selectedSections = $scope.schedule.getSelectedSections()
    str = ''
    for selectedSection in selectedSections
      str += selectedSection.callNumber + ","
    if str and str.charAt(str.length - 1) == ','
      str = str.slice(0, -1)
    $location.hash ''
    $location.search('sections', str)
    $cookies.sectionsString = str

  $scope.getTotalPoints = () ->
    $scope.schedule.getTotalPoints()
    updateURL()

  $scope.sectionSelected = (section, shouldUpdateURL = true) ->
    section.select()
    updateURL() if shouldUpdateURL

  # Course is selected, say from search
  # Course should now be added to the schedule.
  $scope.courseSelect = (course) ->
    Course.fetchByCourseFull(course.CourseFull).then (course) ->
      $scope.schedule.addCourse(course)
      $rootScope.updateURL()
    , (error) ->
      throw error if error
