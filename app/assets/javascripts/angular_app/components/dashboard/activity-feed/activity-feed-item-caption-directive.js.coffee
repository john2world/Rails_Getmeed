# Expects item to be passed in with id, url, title
activityFeedItemCaption = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/dashboard/activity-feed/activity-feed-item-caption.html"
  replace: false
  scope: {
    item: "="
  }
  link: ($scope, elem, attrs) ->
    $timeout ->

activityFeedItemCaption.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "activityFeedItemCaption", activityFeedItemCaption
