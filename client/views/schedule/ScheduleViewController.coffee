@ScheduleViewController = RouteController.extend
  onBeforeAction: ->
    Session.set 'coursesSearchResults', []

    if not Meteor.userId()
      Meteor.loginVisitor()
  onStop: ->
    # Clear search results when leaving page
    Session.set 'coursesSearchResults', []
  onData: ->
    data = @data()
    if data and data.schedule
      courseFulls = data.schedule.getCourseFulls()
      # Reactive join by subscribing to relevant courses
      Meteor.subscribe 'courses', courseFulls
  waitOn: ->
    [
      Meteor.subscribe 'schedules'
    ]
  data: ->
    data =
      searchResults: Session.get 'coursesSearchResults'
      # Should use constants but not working in router.coffee
      semesters: Co.constants.semesters

    # Set semesters to the first one by default
    if data.semesters? and data.semesters.length >= 1
      Session.set 'currentSemester', String data.semesters[0]

    if Co.user()
      data.schedule = Schedules.findOne
        owner: Co.user()._id
        semester: Number Session.get 'currentSemester'

    data
