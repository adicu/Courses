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


  $scope.semesters = CourseHelper.getValidSemesters()
  $scope.selectedSemester = $rootScope.selectedSemester =
    $scope.semesters[0]

  $rootScope.initURL = () ->
    if $cookies.sectionsString == undefined
       $cookies.sectionsString = ""

    if ($location.search()).sections == undefined or ($location.search()).sections.length == 0
        console.log $cookies.sectionsString
        $location.search('sections', $cookies.sectionsString)
    else
        console.log ($location.search()).sections

    $scope.schedule.fillFromURL $scope.selectedSemester

  $rootScope.updateURL = () ->
    selectedSections = $scope.schedule.getSelectedSections()
    str = ''
    for selectedSection in selectedSections
      str += selectedSection.callNumber + ","
    if str and str.charAt(str.length - 1) == ','
      str = str.slice(0, -1)
    $location.hash ''
    $location.search('sections', str)
    $cookies.sectionsString = str

  $rootScope.initURL()

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
      $scope.schedule.addCourse(course,
      (error) ->
        throw error if error
      )
      $rootScope.updateURL()
