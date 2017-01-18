profileCurrentCompany = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-current-company.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->


profileCurrentCompany.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "profileCurrentCompany", profileCurrentCompany
