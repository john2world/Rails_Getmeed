# Expects user and (optional) helper-text to be passed in
posterInfoUser = (CONSTS, $timeout, CurrentUserFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/dashboard/activity-feed/poster-info-user.html"
  replace: false
  scope: {
    user: "="
    feedType: "@"
    helperText: "@"
    time: "="
    collection:"="
    event: "="
  }
  link: ($scope, elem, attrs) ->
    $timeout -> elem.find("abbr.timeago").timeago()

    if CurrentUserFactory.serverSideLoggedIn()
      CurrentUserFactory.getCurrentUser().success (data) ->
        if data.success
          $scope.currentUser = data

posterInfoUser.$inject = [
  "CONSTS"
  "$timeout"
  "CurrentUserFactory"
]

angular.module("meed").directive "posterInfoUser", posterInfoUser
