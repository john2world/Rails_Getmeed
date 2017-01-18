jobFeed = ($timeout, CONSTS, JobFeedUIFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/dashboard/job-feed/job-feed.html"
  replace: true

  link: ($scope, elem, attrs) ->
    $timeout ->
      JobFeedUIFactory.initScrollOnHover()

    $(elem).on "click", ".tab-select", {}, ->
      # TODO: This is a hack
      # Wait until they fade out from the CSS animation
      # Then, set the container width
      $timeout( ->
        JobFeedUIFactory.setJobsContainerWidth()
      , 500)


jobFeed.$inject = [
  "$timeout"
  "CONSTS"
  "JobFeedUIFactory"
]

angular.module("meed").directive "jobFeed", jobFeed
