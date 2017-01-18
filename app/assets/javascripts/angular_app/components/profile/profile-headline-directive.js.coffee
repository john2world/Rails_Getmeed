profileHeadline = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-headline.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->


profileHeadline.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "profileHeadline", profileHeadline
