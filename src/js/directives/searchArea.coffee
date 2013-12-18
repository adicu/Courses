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
    $scope.departments = ["All Departments", "ACLB", "ACTU", "AFSB", "AHAR", "AMSB", "AMST", "ANAT", "ANCB", "ANCS", "ANTB", "ANTH", "APAM", "ARAC", "ARAF", "ARCB", "ARCH", "ARCY", "ARHB", "ASMB", "ASTR", "BCHM", "BIOB", "BIOS", "BIST", "BUSC", "BUSI", "CBME", "CEAC", "CEEM", "CHEM", "CHMB", "CLAS", "CLMS", "CLSB", "CMBS", "CMPL", "COCI", "COLB", "COLM", "COMM", "COMS", "CSER", "CSPB", "DANB", "DESC", "EAEE", "EALC", "ECHB", "ECOB", "ECON", "EDNB", "EEEB", "EESC", "ELEN", "ENCL", "ENGB", "ENGI", "ENSB", "FFPS", "FILB", "FILM", "FRNB", "FRRP", "FUND", "FYSB", "GEND", "GERL", "GRMB", "HINC", "HIST", "HPSC", "HRSB", "HSTB", "HUMR", "ICLS", "IEOR", "INAF", "IRCE", "ITAL", "ITLB", "JAPN", "JAZZ", "JOUC", "LAND", "LAWC", "LAWS", "LING", "LRC", "MATH", "MECE", "MEDI", "MELC", "MIAC", "MICR", "MPAC", "MRSB", "MSAE", "MUSI", "NEUB", "NUTR", "PATH", "PEDB", "PHAR", "PHED", "PHIL", "PHLB", "PHPH", "PHYB", "PHYG", "PHYS", "PLSB", "POLS", "PSYB", "PSYC", "PUHS", "QMSS", "RELB", "RELI", "SCPB", "SCTS", "SCWS", "SIPX", "SLAL", "SOCB", "SOCI", "SOCW", "SOSC", "SPNB", "SPPO", "STAT", "SUDV", "TCOS", "THEA", "THEB", "UBST", "UNSC", "URBS", "URPL", "VIAR", "WMST", "WPGS", "WSTB"]
    $scope.department = $scope.departments[0]
    $scope.searchQuery = ''
    $scope.extraMargin = ''

    # Actual searching function
    runSearch = () ->
      query = $scope.searchQuery

      # append advanced search features
      if not $scope.moreOptionsOff
        if $scope.hasGoldNuggets
          query = query + ' goldnugget'
        if $scope.hasGlobalCores
          query = query + ' globalcore'
        if $scope.professorSearch and $scope.professorSearch.length != 0
          query = query + ' professorsearch ' + $scope.professorSearch
        else if $scope.department != 'All Departments'
          query = query + ' departmentsearch ' + $scope.department

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
      if $scope.extraMargin == ''
        $scope.extraMargin = 'extraMargin'
      else
        $scope.extraMargin = ''