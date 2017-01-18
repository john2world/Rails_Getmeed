profilePublications = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-publications.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->
      # elem.find(".open-profile-apply-modal").click ->
      #   $('#profile-apply-modal').modal()

profilePublications.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "profilePublications", profilePublications
