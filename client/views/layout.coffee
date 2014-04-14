Template.navBar.isActive = (pathName) ->
  current = Router.current()
  return false if not current

  path = Router.routes[pathName].originalPath
  if path == current.route.originalPath
    return 'active'
