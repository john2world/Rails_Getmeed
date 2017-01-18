usersList = ($timeout, CONSTS, CurrentUserFactory) ->

  return {
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/users/users-list.html"
  replace: true
  scope: {
    users: "="
    currentUser: "="
    regFlow: "@"
    source: "@"
  }

  link: ($scope, elem, attrs) ->
    $timeout ->
      $scope.selectedIndex = 0

      if CurrentUserFactory.serverSideLoggedIn()
        CurrentUserFactory.getCurrentUser().success (data) ->
          if data.success
            $scope.currentUser = data
  }

usersList.$inject = [
  "$timeout"
  "CONSTS"
  "CurrentUserFactory"
]

angular.module("meed").directive "usersList", usersList
