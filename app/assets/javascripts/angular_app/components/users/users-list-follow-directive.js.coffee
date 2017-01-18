usersListFollow = ($timeout, CONSTS, CurrentUserFactory, ProfileFactory) ->

  return {
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/users/users-list-follow.html"
  replace: true
  scope: {
    users: "="
    currentUser: "="
    regFlow: "@"
  }

  link: ($scope, elem, attrs) ->
    $scope.follow = (user) ->
      $scope.selectedIndex += 1

      ProfileFactory.followUser(user.handle).success (data) ->
        user.is_viewer_following = true

    $scope.next = ->
      $scope.selectedIndex += 1

    $timeout ->
      $scope.selectedIndex = 0

      if CurrentUserFactory.serverSideLoggedIn()
        CurrentUserFactory.getCurrentUser().success (data) ->
          if data.success
            $scope.currentUser = data
  }

usersListFollow.$inject = [
  "$timeout"
  "CONSTS"
  "CurrentUserFactory"
  "ProfileFactory"
]

angular.module("meed").directive "usersListFollow", usersListFollow
