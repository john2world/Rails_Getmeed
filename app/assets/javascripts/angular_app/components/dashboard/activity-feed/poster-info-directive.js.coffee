# Expects item to be passed in
# TODO: split into two for user, company
posterInfo = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/dashboard/activity-feed/poster-info.html"
  replace: false
  scope: {
    item: "="
  }
  link: ($scope, elem, attrs) ->
    $timeout ->


posterInfo.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "posterInfo", posterInfo
