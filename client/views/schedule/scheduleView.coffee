SEARCH_TIMEOUT = 750

Template.scheduleSearchArea.semesterClasses = ->
  selectedSemester = String @
  currentSemester = Session.get 'currentSemester'

  if selectedSemester == currentSemester
    return ['active']

# Clears the search bar and search results
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
    schedule.addCourse @CourseFull, (err) ->
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


# Returns credit or credits based on number of points
Template.scheduleSidebar.formatCreditLabel = ->
  points = @schedule.getTotalPoints()
  if points == 1
    return 'credit'
  else
    return 'credits'


SECTIONS_LIMIT = 4
Template.scheduleSidebarItem.getAbbrevSections = ->
  return @course.getSections limit: SECTIONS_LIMIT

# Checks if the number of sections is greater than some limit
Template.scheduleSidebarItem.hasMoreSections = ->
  return @course.getSections().count() > SECTIONS_LIMIT

Template.scheduleSidebarItem.events
  'click input.sectionSelect': (e) ->
    input = e.target
    checked = input.checked
    if checked
      @schedule.addSection @section.sectionFull
    else
      @schedule.removeSection @section.sectionFull
  'click .deleteCourse': (e) ->
    @schedule.removeCourse @course.courseFull
