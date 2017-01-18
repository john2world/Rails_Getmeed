experienceEntryEdit = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/experience-entry-edit.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->
      # Do nothing

experienceEntryEdit.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "experienceEntryEdit", experienceEntryEdit
