jobListEntry = ($timeout, CONSTS, HorizontalFeedUiFactory) ->

  ctrl = ($scope) ->
    job = $scope.job
    job.linkUrl = "/job/#{job.slug_id}/"

  ctrl.$inject = [
    "$scope"
  ]


  linkFn = ($scope, elem, attrs) ->
    $timeout ->
      feedItemSelector = "job-list-entry"
      innerWrapSelector = "#category-jobs-feed .horizontal-feed-inner-wrap"
      HorizontalFeedUiFactory.setInnerWrapWidth(feedItemSelector, innerWrapSelector)

  return {
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/jobs/job-list-entry.html"
  replace: true
  scope: {
    job: "="
    currentUser: "="
  }
  controller: ctrl
  link: linkFn
  }

jobListEntry.$inject = [
  "$timeout"
  "CONSTS"
  "HorizontalFeedUiFactory"
]

angular.module("meed").directive "jobListEntry", jobListEntry
