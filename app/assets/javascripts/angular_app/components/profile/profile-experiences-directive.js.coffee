profileExperiences = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-experiences.html"
  replace: false

  scope: {
    profile: "="
    fns: "="
    months: "="
    years: "="
  }

  link: ($scope, elem, attrs) ->
    $timeout ->
      # elem.find(".open-profile-apply-modal").click ->
      #   $('#profile-apply-modal').modal()

profileExperiences.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "profileExperiences", profileExperiences
