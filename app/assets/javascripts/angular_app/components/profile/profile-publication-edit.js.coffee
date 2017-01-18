profilePublicationEdit = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-publication-edit.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->


profilePublicationEdit.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "profilePublicationEdit", profilePublicationEdit
