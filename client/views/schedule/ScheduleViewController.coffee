@ScheduleViewController = RouteController.extend
  onBeforeAction: ->
    Session.set 'coursesSearchResults', []

    if not Meteor.userId()
      Meteor.loginVisitor()
  onStop: ->
    # Clear search results when leaving page
    Session.set 'coursesSearchResults', []
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

    data
