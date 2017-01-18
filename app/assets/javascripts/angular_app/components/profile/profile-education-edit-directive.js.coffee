profileEducationEdit = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-education-edit.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->
      $(elem).find(".major-select, .degree-select").selectize()

profileEducationEdit.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "profileEducationEdit", profileEducationEdit
