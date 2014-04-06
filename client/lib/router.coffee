# Configuration of iron-router
# Run by default on page load

Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'

Router.onBeforeAction 'loading'

Router.map ->
  @route 'home',
    path: '/'
    onBeforeAction: ->
      Router.go 'scheduleView'

  @route 'scheduleView',
    path: '/schedule'
    onBeforeAction: ->
      Session.set 'coursesSearchResults', []
    onStop: ->
      # Clear search results when leaving page
      Session.set 'coursesSearchResults', []
    data: ->
      data =
        schedule: []
        searchResults: Session.get 'coursesSearchResults'
        # Should use constants but not working in router.coffee
        semesters: Co.constants.semesters

      # Set semesters to the first one by default
      if data.semesters? and data.semesters.length >= 1
        Session.set 'currentSemester', String data.semesters[0]

      data

  @route 'directoryView',
    path: '/directory'
