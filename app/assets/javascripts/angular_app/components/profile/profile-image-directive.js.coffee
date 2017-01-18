profileImage = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-image.html"
  replace: true
  link: ($scope, elem, attrs) ->

profileImage.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "profileImage", profileImage
