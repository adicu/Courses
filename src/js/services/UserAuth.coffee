angular.module('Courses.services')
.factory 'UserAuth', (
  $rootScope,
  $FB,
  $q,
) ->
  fbInit: () ->
    $FB.getLoginStatus()
      .then (res) =>
        console.log 'fbres', res
        if res.status is 'connected'
          @fbGetUserInfo()
        else
          @fbWatch()

  fbWatch: () ->
    $FB.Event.subscribe 'auth.statusChange', (res) =>
      console.log 'fbres', res
      if res.status is 'connected'
        @fbGetUserInfo()
      else
        $rootScope.fbUser = null

  fbGetUserInfo: () ->
    $q.all([
      $FB.api('/me'),
      $FB.api('/me/picture'),
    ])
    .then (res) ->
      console.log 'fbUser', res[0]
      $rootScope.fbUser = res[0]
      if $rootScope.fbUser
        $rootScope.fbUser.picture =
          "http://graph.facebook.com/#{$rootScope.fbUser.id}/picture"

      console.log res[1]

  # @return Promise<Boolean> if the user is logged into Facebook,
  #   resolve to true when auth finishes.
  pWaitForFb : () ->
    d = $q.defer()

    $rootScope.$watch 'fbUser', () ->
      d.resolve Boolean $rootScope.fbUser

    d.promise
