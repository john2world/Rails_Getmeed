DashboardController = ($scope,
                       $routeParams,
                       UTILS,
                       CollectionFactory,
                       CollectionsFactory,
                       CurrentUserFactory,
                       ActivityFeedFactory,
                       ActivityFeedItemFactory) ->
  $scope.activityFeedLoaded = false
  $scope.regFlow = false
  if $routeParams.lb
    $scope.regFlow = true

  UTILS.setPageTitle("Home")
  $scope.page = 1
  $scope.filter_page = 1
  $scope.pageSize = 5
  $scope.hasFeedItems = false
  $scope.schoolFilter = null
  if CurrentUserFactory.serverSideLoggedIn()
    $scope.loggedIn = true
    CurrentUserFactory.getCurrentUser().success (data) ->
      if data.success
        $scope.currentUser = data

        if $scope.currentUser.badge != 'influencer'
          $scope.placeholderText = "Share news and thoughts, upload original projects and coursework, or ask questions to add credibility to your profile!"
          $scope.placeholderTextForQuestion = "Ask a question about a company or a project you are working on. Someone related will answer it. Please use appropriate tags!"
        else
          $scope.placeholderText = "Share news and thoughts about your company or links to the blogs you've written or share any knowledge that's helpful for students"
          $scope.placeholderTextForAMA = "(Ask Me Anything) is a nice way to introduce yourself, brief your expertise and tell students how can you help them - they'll ask questions as comments to this post!"

  handleFeedResponse = (data) ->
    $scope.feedItems = data.feed.map((e) ->
      new ActivityFeedItemFactory(e)
    )
    $scope.allFeedActions = data.actions
    $scope.hasFeedItems = $scope.feedItems.length > 0
    $scope.loading = false

  loadFeed = ->
    if $scope.schoolFilter
      $scope.page = 1
      ActivityFeedFactory.getUniversityFeedForPage($scope.filter_page++, $scope.pageSize).success handleFeedResponse
    else
      $scope.filter_page = 1
      ActivityFeedFactory.getFeedForPage($scope.page++, $scope.pageSize).success handleFeedResponse

  loadFeed()

  $scope.setSchool = (schoolHandle) ->
    $scope.hasFeedItems = false
    $scope.schoolFilter = schoolHandle
    loadFeed()

DashboardController.$inject = [
  "$scope"
  "$routeParams"
  "UTILS"
  "CollectionFactory"
  "CollectionsFactory"
  "CurrentUserFactory"
  "ActivityFeedFactory"
  "ActivityFeedItemFactory"
]

angular.module("meed").controller "DashboardController", DashboardController
