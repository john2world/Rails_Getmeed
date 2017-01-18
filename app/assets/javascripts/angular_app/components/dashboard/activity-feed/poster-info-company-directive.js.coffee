# Expects company and (optional) helper-text to be passed in
posterInfoCompany = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/dashboard/activity-feed/poster-info-company.html"
  replace: false
  scope: {
    company: "="
    helperText: "@"
  }
  link: ($scope, elem, attrs) ->
    $timeout ->


posterInfoCompany.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "posterInfoCompany", posterInfoCompany
