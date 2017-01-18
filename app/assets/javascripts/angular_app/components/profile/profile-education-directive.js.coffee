profileEducation = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-education.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->
      # elem.find(".open-profile-apply-modal").click ->
      #   $('#profile-apply-modal').modal()

profileEducation.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "profileEducation", profileEducation
