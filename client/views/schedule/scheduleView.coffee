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
    Schedules.addCourse schedule._id, @CourseFull, (err) ->
      handleError err if err
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


Template.scheduleWeekView.days = ->
  [0..4]

Template.scheduleWeekView.hours = ->
  [8..23]

Template.scheduleWeekView.getSectionsForDay = (day) ->
  return []


Template.scheduleView.schedule = ->
  if Co.user()
    schedule = Schedules.findOne
      owner: Co.user()._id
      semester: Number Session.get 'currentSemester'
  return schedule
