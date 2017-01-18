CollectionController = (
  $scope,
  $routeParams,
  $timeout,
  UTILS,
  ActivityFeedItemFactory,
  CollectionsFactory,
  CollectionFactory,
  CurrentUserFactory) ->

  collectionId = $routeParams.collectionId
  slugId = $routeParams.slugId

  $scope.loading = true

  CollectionsFactory.getCollectionFull(slugId, collectionId, 1, 7).success (data) ->
    $scope.loading = false
    $scope.collection = new CollectionFactory(data.collection)
    UTILS.setPageTitle($scope.collection.title)
    $scope.feedItems = data.feed_items.map (e) ->
      new ActivityFeedItemFactory(e)

    if data.recommended_collections
      $scope.recommendedCollections = data.recommended_collections.map (e) ->
        new CollectionFactory(e)


  if CurrentUserFactory.serverSideLoggedIn()
    CurrentUserFactory.getCurrentUser().success (data) ->
      if data.success
        $scope.currentUser = data



CollectionController.$inject = [
  "$scope"
  "$routeParams"
  "$timeout"
  "UTILS"
  "ActivityFeedItemFactory"
  "CollectionsFactory"
  "CollectionFactory"
  "CurrentUserFactory"
]

angular.module("meed").controller "CollectionController", CollectionController
