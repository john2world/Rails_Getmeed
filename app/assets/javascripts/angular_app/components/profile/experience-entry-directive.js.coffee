experienceEntry = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/experience-entry.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->

experienceEntry.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "experienceEntry", experienceEntry
