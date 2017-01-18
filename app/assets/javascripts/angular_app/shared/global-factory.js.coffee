GLOBALS = (MeedApiFactory, CurrentUserFactory) ->
  currentUser = () ->
    CurrentUserFactory.getCurrentUser()

  return {
    currentUser: currentUser
  }

GLOBALS.$inject = [
  "MeedApiFactory"
  "CurrentUserFactory"
]

angular.module("meed").factory "GLOBALS", GLOBALS
