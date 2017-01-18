influencersProfile = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/influencers-profile.html"
  replace: true
  link: ($scope, elem, attrs) ->

influencersProfile.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "influencersProfile", influencersProfile
