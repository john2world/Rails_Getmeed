CurrentUserFactory = (MeedApiFactory) ->
  _currentUser = MeedApiFactory.get({url: "/users/get_current_user", cached: true})

  getCurrentUser = () -> _currentUser

  getCurrentUserWithoutCache = () ->
    MeedApiFactory.get({url: "/users/get_current_user?force=true", cached: false})

  # Not secure because it's just based on assigning a class to the body tag
  # Users won't be able to do anything real unless getCurrentUser succeseds
  # We use this function to check if we even want to try to grab currentUser
  serverSideLoggedIn = () ->
    document.querySelector("body.logged-in")

  updateCurrentUser = (scope) ->
    if serverSideLoggedIn()
      getCurrentUserWithoutCache().success (data) ->
        if data.success
          scope.currentUser = data

  return {
    getCurrentUser: getCurrentUser
    serverSideLoggedIn: serverSideLoggedIn
    updateCurrentUser: updateCurrentUser
  }

CurrentUserFactory.$inject = [
  "MeedApiFactory"
]

angular.module("meed").factory "CurrentUserFactory", CurrentUserFactory
