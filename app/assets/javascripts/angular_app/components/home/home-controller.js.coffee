HomeController = (
  $scope,
  $timeout,
  $routeParams,
  UTILS,
  CurrentUserFactory,
  HeaderNavFactory,
  SignupFactory,
  RedirectFactory) ->

  $scope.loggedIn = false
  $scope.loggedIn = CurrentUserFactory.serverSideLoggedIn()

  if $scope.loggedIn
    CurrentUserFactory.getCurrentUser().success (data) ->
      if data.success
        $scope.currentUser = data
  else
    $timeout ->
      $buttons = $(".follow, .unfollow, .give-kudos, .write-meed-post, .view-job")
      $buttons.off("click")
      $buttons.attr("ng-click", "")
      $buttons.on "click", (e) ->
        e.preventDefault()
        HeaderNavFactory.openSignupModal()
    # populate only if the user is not logged in
    if $routeParams.school
      $scope.school = $routeParams.school

    if $routeParams.majortype
      $scope.majortype= $routeParams.majortype

    if $routeParams.year
      $scope.year = $routeParams.year



HomeController.$inject = [
  "$scope"
  "$timeout"
  "$routeParams"
  "UTILS"
  "CurrentUserFactory"
  "HeaderNavFactory"
  "SignupFactory"
  "RedirectFactory"
]

angular.module("meed").controller "HomeController", HomeController
