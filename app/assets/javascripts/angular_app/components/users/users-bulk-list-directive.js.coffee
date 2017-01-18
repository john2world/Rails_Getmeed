usersBulkList = ($timeout, CONSTS, CurrentUserFactory) ->

  return {
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/users/users-bulk-list.html"
  replace: true
  scope: {
    users: "="
    currentUser: "="
    regFlow: "@"
  }

  link: ($scope, elem, attrs) ->
    $timeout ->
      if CurrentUserFactory.serverSideLoggedIn()
        CurrentUserFactory.getCurrentUser().success (data) ->
          if data.success
            $scope.currentUser = data

  }

usersBulkList.$inject = [
  "$timeout"
  "CONSTS"
  "CurrentUserFactory"
]

angular.module("meed").directive "usersBulkList", usersBulkList
