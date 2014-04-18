// Configuration of iron-router
// Run by default on page load
// Base templates in /client/views
Router.configure({
  layoutTemplate: 'layout',
  loadingTemplate: 'loading'
});

Router.onBeforeAction('loading');

// Associated controllers are in their respective directories
// in views, mapped automatically by name
// route name + Controller
// Ex. /schedule has a controller
// /client/views/schedule/ScheduleViewController.coffee
Router.map(function() {
  this.route('home', {
    path: '/',
    onBeforeAction: function() {
      return Router.go('scheduleView');
    }
  });

  this.route('scheduleView', {
    path: '/schedule'
  });

  this.route('directoryView', {
    path: '/directory'
  });
});
