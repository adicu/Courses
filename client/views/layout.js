Template.navBar.isActive = function(pathName) {
  var current = Router.current();
  if (!current) {
    return false;
  }
  var path = Router.routes[pathName].originalPath;
  if (path === current.route.originalPath) {
    return 'active';
  }
};
