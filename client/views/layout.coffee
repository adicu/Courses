Template.navBar.isActive = (pathName) ->
  current = Router.current()
  return false if not current

  path = Router.routes[pathName].path()
  if path == current.path
    return 'active'
