# Controller for viewing a single job
# TODO: refactor
JobController = (
  $scope,
  $routeParams,
  $timeout,
  $interval,
  UTILS,
  CurrentUserFactory,
  JobFactory,
  CollectionsFactory,
  CollectionFactory,
  JobFeedCurrentJobFactory,
  MeedApiFactory) ->

  $scope.currentJob = JobFeedCurrentJobFactory
  CurrentUserFactory.getCurrentUser().success (data) ->
    if data.success
      $scope.currentUser = data

  $scope.resetJob = () ->
    $timeout ->
      $scope.job = null

  userFollowingCollectionCb = (data) ->
    $scope.loading = false
    if data.collections
      $scope.userCollections = data.collections.map (e) ->
        new CollectionFactory(e)

    if data.trending_tags
      $scope.trendingTags = data.trending_tags

  userCollectionsCb = (data) ->
    $scope.loading = false
    $scope.tags = data.tags
    $scope.publicCollections = data.public_collections.map (e) ->
      new CollectionFactory(e)
    $scope.allCollections = $scope.publicCollections

  $scope.getJob = (slug) ->
    JobFactory.getJob(slug).success (data) ->
      $scope.job = data.job

      # TODO: refactor?
      $scope.job.applyModalTitle = () ->
        return "Cover Note (Optional)" if !$scope.job.question
        if $scope.currentUser.is_profile_incomplete
          return "Your profile is incomplete"
        else if $scope.job.question
          return "Answer Question"
      $scope.metadata = data.metadata
      company = data.company
      if company.video_urls.length > 1
        company.video_urls = company.video_urls.unique()

      $scope.company = company
      $scope.applied = data.applied

      window.scrollTo(0, 0)
      UTILS.setPageTitle("#{$scope.job.title} at #{$scope.job.company}")

  $scope.getJob($routeParams.jobSlug)
  CollectionsFactory.getUserFollowingCollectionsCached(userFollowingCollectionCb)
  CollectionsFactory.getUserCollectionsCached(userCollectionsCb)

  $timeout ->
    if $routeParams.stm
      $interval(() ->
        UTILS.openModal "#signup-modal", {
          overlay:     false
          escapeClose: true
          clickClose:  true
          showSpinner: false
          showClose:   true
        }
      ,5000)



JobController.$inject = [
  "$scope"
  "$routeParams"
  "$timeout"
  "$interval"
  "UTILS"
  "CurrentUserFactory"
  "JobFactory"
  "CollectionsFactory",
  "CollectionFactory",
  "JobFeedCurrentJobFactory"
  "MeedApiFactory"
]

angular.module("meed").controller "JobController", JobController
