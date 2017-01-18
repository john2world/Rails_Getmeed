RecommendedCollectionsController = ($scope, CollectionFactory, CollectionsFactory) ->
  CollectionsFactory.getRecommendedCollections().success (data) ->
   if data.recommended_collections
      $scope.recommendedCollections = data.recommended_collections.map (e) ->
        new CollectionFactory(e)
      $scope.joinedCollections = data.following_collections.map (e) ->
        new CollectionFactory(e)


RecommendedCollectionsController.$inject = [
  "$scope"
  "CollectionFactory"
  "CollectionsFactory"
]

angular.module("meed").controller "RecommendedCollectionsController", RecommendedCollectionsController


