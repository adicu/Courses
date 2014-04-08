# Configuration of iron-router
# Run by default on page load

Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'

Router.onBeforeAction 'loading'

# Associated controllers are in their respective directories
# in views, mapped automatically by name
Router.map ->
  @route 'home',
    path: '/'
    onBeforeAction: ->
      Router.go 'scheduleView'

  @route 'scheduleView',
    path: '/schedule'

  @route 'directoryView',
    path: '/directory'
