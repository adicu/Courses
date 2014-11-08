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
    onAfterAction: function() {
      // Redirect to schedule by default
      Co.smartRedirect.call(this, 'scheduleView');
    },
    unload: function() {
      Co.routerPrevPath = this.path;
    }
  });

  this.route('scheduleView', {
    path: '/schedule/:_id?'
  });

  this.route('directorySingle', {
    path: '/directory/:courseFull'
  });

  this.route('about', {
    path: '/about'
  });
});

// iron-router-progress config
IronRouterProgress.configure({
  delay: 50,
  spinner: false
});
