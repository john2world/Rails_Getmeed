TagsController = (
  $scope,
  $routeParams,
  $timeout,
  UTILS,
  ActivityFeedFactory,
  ActivityFeedItemFactory,
  CurrentUserFactory) ->


  $scope.loading = true
  tagId = $routeParams.tagId

  ActivityFeedFactory.getFeedForTag(tagId, 1, 5).success (data) ->
    $scope.loading = false
    $scope.tag = data.tag
    UTILS.setPageTitle($scope.tag.title)
    $scope.feedItems = data.feed_items.map (e) ->
      new ActivityFeedItemFactory(e)


  if CurrentUserFactory.serverSideLoggedIn()
    CurrentUserFactory.getCurrentUser().success (data) ->
      if data.success
        $scope.currentUser = data



TagsController.$inject = [
  "$scope"
  "$routeParams"
  "$timeout"
  "UTILS"
  "ActivityFeedFactory"
  "ActivityFeedItemFactory"
  "CurrentUserFactory"
]

angular.module("meed").controller "TagsController", TagsController
