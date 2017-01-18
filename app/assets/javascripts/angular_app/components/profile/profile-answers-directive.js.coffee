profileAnswers = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-answers.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->
      # elem.find(".open-profile-apply-modal").click ->
      #   $('#profile-apply-modal').modal()

profileAnswers.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "profileAnswers", profileAnswers
