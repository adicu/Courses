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
    $scope.searchQuery = ''

    # Actual searching function
    runSearch = () ->
      query = $scope.searchQuery

      options = {}
      # append advanced search features
      if not $scope.moreOptionsOff
        if $scope.hasGlobalCores
          options.globalCore = true
        if $scope.professorSearch and $scope.professorSearch.length != 0
          options.professorSearch = $scope.professorSearch

      if not query and not options
        $scope.clearResults()
        return
      Course.search(query, $scope.selectedSemester, options)
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

    $scope.optionsText = ->
      if $scope.moreOptionsOff
        return 'More Options'
      else
        return 'Less Options'

    $scope.optionsIcon = ->
      if $scope.moreOptionsOff
        return 'fa-angle-down'
      else
        return 'fa-angle-right'

    $scope.extraMargin = ->
      if $scope.moreOptionsOff
        return ''
      else
        return 'extraMargin'

    $scope.toggleOptions =  ->
      $scope.moreOptionsOff = not $scope.moreOptionsOff
