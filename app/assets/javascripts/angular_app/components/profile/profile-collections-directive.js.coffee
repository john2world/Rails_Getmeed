profileCollections = ($timeout, CONSTS, CurrentUserFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-collections.html"
  replace: true
  scope:{
    profile: "="
    currentUser: "="
  }
  link: ($scope, elem, attrs) ->
    $timeout ->
    CurrentUserFactory.getCurrentUser().success (data) ->
      if data.success
        $scope.currentUser = data


profileCollections.$inject = [
  "$timeout"
  "CONSTS"
  "CurrentUserFactory"
]

angular.module("meed").directive "profileCollections", profileCollections
