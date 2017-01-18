AmaController = (
  $scope,
  $location,
  $timeout,
  $routeParams,
  CurrentUserFactory,
  AmaFactory,
  ActivityFeedItemFactory,
  HeaderNavFactory,
  CommentFactory) ->

  $scope.amaId = $routeParams.ama_id
  $scope.loadAma = (amaId) ->
    AmaFactory.getEvent(amaId).then (response) ->
      event = response.data
      #event = new ActivityFeedItemFactory(data.event)
      if event.feed_items
        event.feed_items = event.feed_items.map( (e) ->
          new ActivityFeedItemFactory(e)
        )
      $scope.ama = event
      $scope.isFollowing = $scope.ama.following

  $scope.ama = AmaFactory.getCachedEvent($scope.amaId)

  $timeout ->
    HeaderNavFactory.setBgHidden(true)

AmaController.$inject = [
  "$scope"
  "$location"
  "$timeout"
  "$routeParams"
  "CurrentUserFactory"
  "AmaFactory"
  "ActivityFeedItemFactory"
  "HeaderNavFactory"
  "CommentFactory"
]

angular.module("meed").controller "AmaController", AmaController
