influencerSignupForm = ($timeout, CONSTS) ->

  linkFn = ($scope, elem, attrs) ->
# $timeout ->
#   $(elem).find("select").selectize()

  return {
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/signup/influencer-signup-form.html"
  replace: true
  controller: "InfluencersController"
  link: linkFn
  }

influencerSignupForm.$inject = [
  "$timeout"
  "CONSTS"
  "UTILS"
]

angular.module("meed").directive "influencerSignupForm", influencerSignupForm
