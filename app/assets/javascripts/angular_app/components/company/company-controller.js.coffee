CompanyController = (
  $scope,
  $routeParams,
  UTILS,
  CompanyFactory,
  CurrentUserFactory,
  ActivityFeedItemFactory,
  JobFeedFactory) ->

  # TODO: move to global CurrentUser object
  CurrentUserFactory.getCurrentUser().success (data) ->
    if data.success
      $scope.currentUser = data

  CompanyFactory.getCompany($routeParams.companySlug).success (data) ->
    $scope.jobs = data.jobs
    JobFeedFactory.setJobCounts($scope)
    if data.feed_items.feed and data.feed_items.feed.length > 0
      $scope.allFeedItems  = data.feed_items.feed.map( (e) ->
        new ActivityFeedItemFactory(e)
      )
      $scope.allFeedActions = data.feed_items.actions
    else
      $scope.noFeedItems = true

    company = data.company
    if company.video_urls.length > 1
      company.video_urls = company.video_urls.unique()

    $scope.company = company
    $scope.follow = () ->
      CompanyFactory.follow(company._id).success (data) ->
        $scope.company.is_viewer_following = true

    $scope.unfollow = () ->
      CompanyFactory.unfollow(company._id).success (data) ->
        $scope.company.is_viewer_following = false

    UTILS.setPageTitle("Come work for #{company.name}!")


CompanyController.$inject = [
  "$scope"
  "$routeParams"
  "UTILS"
  "CompanyFactory"
  "CurrentUserFactory"
  "ActivityFeedItemFactory"
  "JobFeedFactory"
]

angular.module("meed").controller "CompanyController", CompanyController
