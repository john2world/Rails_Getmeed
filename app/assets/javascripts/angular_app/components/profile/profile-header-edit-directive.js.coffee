profileHeaderEdit = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-header-edit.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->
      $(elem.find("select")).selectize()

profileHeaderEdit.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "profileHeaderEdit", profileHeaderEdit
