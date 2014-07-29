Template.navBarRightItems.isActive = function(pathName) {
  var current = Router.current();
  if (!current) {
    return false;
  }
  var path = Router.routes[pathName].originalPath;
  if (path === current.route.originalPath) {
    return 'active';
  }
};

Template.navBarRightItems.events({
  'click a.facebook-auth': function(e) {
    Co.loginWithFacebook();
  },
  'click a.logout-auth': function(e) {
    Co.logout();
  }
});

Template.analytics.created = function() {
  Co.analytics.start();
}
