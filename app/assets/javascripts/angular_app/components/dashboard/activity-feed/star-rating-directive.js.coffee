starRating = ($timeout, CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/dashboard/activity-feed/star-rating.html"
  replace: true
  scope: {
    rating: "@"
  }
  link: ($scope, elem, attrs) ->
    $timeout ->
      # Do stuff

    $scope.range = (n) ->
      new Array(n)

starRating.$inject = [
  "$timeout"
  "CONSTS"
]

angular.module("meed").directive "starRating", starRating
