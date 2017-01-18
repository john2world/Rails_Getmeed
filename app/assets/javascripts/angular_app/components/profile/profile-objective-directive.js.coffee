profileObjective = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-objective.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->
      # elem.find(".open-profile-apply-modal").click ->
      #   $('#profile-apply-modal').modal()

profileObjective.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "profileObjective", profileObjective
