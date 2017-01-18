jobFeedItem = ($timeout, CONSTS, JobFeedUIFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/dashboard/job-feed/job-feed-item.html"
  replace: true

  link: ($scope, elem, attrs) ->

jobFeedItem.$inject = [
  "$timeout"
  "CONSTS"
  "JobFeedUIFactory"
]

angular.module("meed").directive "jobFeedItem", jobFeedItem
