SEARCH_TIMEOUT = 750

Template.scheduleSearchArea.semesterClasses = ->
  selectedSemester = String @
  currentSemester = Session.get 'currentSemester'

  if selectedSemester == currentSemester
    return ['active']

resetSearch = ->
  searchInput = $ '#searchInput'
  searchInput.value = ''
  Session.set 'coursesSearchResults', []

searchTimeout = null

Template.scheduleSearchArea.events
  'click .semesterToggle': (e) ->
    selectedSemester = String @
    Session.set 'currentSemester', String selectedSemester

  'click .courseResultItem': (e) ->
    newCourse = Courses.find
      courseFull: @CourseFull
    resetSearch()

  'input input': (e) ->
    input = e.target

    query = input.value
    # Run search after set interval if not queued already
    if searchTimeout
      Meteor.clearTimeout searchTimeout

    searchTimeout = Meteor.setTimeout ->
      if query
        Courses.search query
      else
        resetSearch()
      searchTimeout = null
    , SEARCH_TIMEOUT


Template.scheduleWeekView.getDays = ->
  [0..4]

Template.scheduleWeekView.getHours = ->
  [8..23]

Template.scheduleWeekView.getSectionsForDay = (day) ->
  return []


Template.scheduleSidebar.hasCourses = ->
  return false
