profileBio = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-bio.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->


profileBio.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "profileBio", profileBio
