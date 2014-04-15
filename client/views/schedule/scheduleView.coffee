SEARCH_TIMEOUT = 750

Template.scheduleSearchArea.semesterClasses = ->
  selectedSemester = String @
  currentSemester = Session.get 'currentSemester'

  if selectedSemester == currentSemester
    return ['active']

# Clears the search bar and search results
resetSearch = ->
  searchInput = $ '#searchInput'
  searchInput.val ''
  Session.set 'coursesSearchResults', []

searchTimeout = null

createOrGetSchedule = ->
  semester = Session.get 'currentSemester'
  user = Co.user()

  if user
    schedules = user.profile.schedules
    if schedules and schedules[semester]
      schedule = Schedules.findOne schedules[semester]
      return schedule
    else
      newSchedule = Schedules.insert
        semester: Number semester
      schedule = Schedules.findOne newSchedule
      return schedule
  else
    handleError new Error 'No user!'

getSchedule = ->
  semester = Session.get 'currentSemester'
  user = Co.user()

  if user
    schedules = user.profile.schedules
    if schedules and schedules[semester]
      return Schedules.findOne schedules[semester]

Template.scheduleSearchArea.events
  'click .semesterToggle': (e) ->
    selectedSemester = String @
    Session.set 'currentSemester', String selectedSemester

  'click .courseResultItem': (e) ->
    schedule = createOrGetSchedule()
    schedule.addCourse @CourseFull, (err) =>
      handleError err if err
      Template.scheduleSidebar.openAccordion @CourseFull
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


# Runs automatically when template is rendered
scheduleComputation = undefined
Template.scheduleWeekView.rendered = ->
  startDate = Co.courseHelper.getCurrentSemesterDates().start
  # Will be populated by the autorun whenever
  # schedule or sections changes
  fcEvents = []
  $('#calendar').fullCalendar
    events: (start, end, callback) ->
      callback fcEvents
    eventClick: (fcEvent, e, view) ->
      Template.scheduleSidebar.toggleAccordion fcEvent.courseFull
    weekends: false
    defaultView: 'agendaWeek'     # Just show week view
    header: false                 # Disable the default headers
    allDaySlot: false             # Disable all day header
    allDayDefault: false          # Make events default not all day
    columnFormat:
      week: 'dddd'                # Don't show the specific day
    minTime: 7                    # Start at 7am
    height: 100000                # Force full view

    year: startDate.year()
    month: startDate.month()
    # Finds the next Monday after the start and
    # returns the date of the month
    date: moment(startDate).day(1).date()

  scheduleComputation = Deps.autorun ->
    schedule = getSchedule()
    return if not schedule
    fcEvents = schedule.toFCEvents()
    $('#calendar').fullCalendar 'refetchEvents'

Template.scheduleWeekView.destroyed = ->
  # Clean up our autorunning
  if scheduleComputation
    scheduleComputation.stop()
