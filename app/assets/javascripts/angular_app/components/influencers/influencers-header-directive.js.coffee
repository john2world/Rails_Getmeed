influencersHeader = ($timeout, $location, UTILS, CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/influencers/influencers-header.html"
  replace: true
  scope: {
    currentUser: "="
    profile: "="
  }

  link: ($scope, elem, attrs) ->
    $timeout ->
influencersHeader.$inject = [
  "$timeout"
  "$location"
  "UTILS"
  "CONSTS"
]

angular.module("meed").directive "influencersHeader", influencersHeader
