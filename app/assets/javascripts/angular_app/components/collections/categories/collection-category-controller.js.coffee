CollectionCategoryController = (
  $scope,
  $routeParams,
  UTILS,
  ActivityFeedItemFactory,
  CollectionFactory,
  CollectionCategoriesFactory) ->

  CollectionCategoriesFactory.getCategory($routeParams.categorySlug).success (data) ->
    $scope.loading = false
    $scope.publicCollections = data.public_collections.map (e) ->
      new CollectionFactory(e)
    $scope.privateCollections = data.private_collections.map (e) ->
      new CollectionFactory(e)

    $scope.category = data.category
    $scope.allCollections = $scope.publicCollections.concat $scope.privateCollections
    if slug == 'public'
      $scope.allCollections = $scope.publicCollections
    else
      $scope.allCollections = $scope.privateCollections

    UTILS.setPageTitle("Top Groups in #{$scope.category.title}")

CollectionCategoryController.$inject = [
  "$scope"
  "$routeParams"
  "UTILS"
  "ActivityFeedItemFactory"
  "CollectionFactory"
  "CollectionCategoriesFactory"
]

angular.module("meed").controller "CollectionCategoryController", CollectionCategoryController
