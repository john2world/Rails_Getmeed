profilePreviousCompanies = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-previous-companies.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->


profilePreviousCompanies.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "profilePreviousCompanies", profilePreviousCompanies
