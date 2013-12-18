angular.module('Courses.directives')
.directive 'searchArea', (
  $rootScope,
  $timeout,
  Course,
  CourseHelper,
) ->
  templateUrl: 'partials/directives/searchArea.html'
  restrict: 'E'
  scope:
    onselect: '&'
    schedule: '='
    semesters: '='

  controller: ($scope, $element, $attrs, $timeout) ->
    $scope.searchResults = []
    previousSearch = null

    $scope.selectedSemester = $rootScope.selectedSemester =
      $scope.semesters[0]
    $scope.schedule.semester $scope.selectedSemester

    $scope.$watch 'selectedSemester', (newSemester) ->
      $scope.schedule.semester newSemester

    $scope.moreOptionsOff = true
    $scope.optionsText = 'More Options'
    $scope.optionsIcon = 'fa-angle-right'

    # Actual searching function
    runSearch = () ->
      query = $scope.searchQuery

      # append advanced search features
      if $scope.hasGoldNuggets
        query = query + ' goldnugget'
      if $scope.hasGlobalCores
        query = query + ' globalcore'
      if not query or query.length == 0
        $scope.clearResults()
        return
      Course.search(query, $scope.selectedSemester)
        .then (data) ->
          if data == 'callnum'
            $scope.clearResults()
            # TODO: Success message
          else
            $scope.searchResults = data

    # Will run searches after a delay
    $scope.search = () ->
      # Cancel the previous search if it hasn't started
      $timeout.cancel previousSearch if previousSearch
      previousSearch = $timeout runSearch, 400
      previousSearch.then (data) ->
        # Search has finshed, clear previousSearch
        previousSearch = null

    $scope.courseSelect = (course) ->
      $scope.clearResults()
      $scope.onselect course

    $scope.clearResults = () ->
      $scope.searchResults = []
      $scope.searchQuery = ""

    $scope.changeSemester = (newSemester) ->
      $scope.selectedSemester = newSemester

    $scope.toggleOptions = (moreOptionsStatus) ->
      $scope.moreOptionsOff = !moreOptionsStatus
      if $scope.optionsText == 'More Options'
        $scope.optionsText = 'Less Options'
      else
        $scope.optionsText = 'More Options'
      if $scope.optionsIcon == 'fa-angle-right'
        $scope.optionsIcon = 'fa-angle-down'
      else
        $scope.optionsIcon = 'fa-angle-right'