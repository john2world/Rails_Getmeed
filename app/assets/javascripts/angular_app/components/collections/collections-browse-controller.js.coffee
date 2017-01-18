CollectionsBrowseController = (
  $scope,
  $location,
  $routeParams,
  $timeout,
  CurrentUserFactory,
  CollectionFactory,
  CollectionCategoriesFactory) ->

  $scope.showNew = true
  $scope.loading = true

  $scope.loadCategory = (slug) ->
    $(".collection-category-list-entry a").removeClass("active")
    $("#category-#{slug} a").addClass("active")
    $location.path("/categories/#{slug.toLowerCase()}", false)
    $scope.loading = true
    if $routeParams.categorySlug
      CollectionCategoriesFactory.getCategory($routeParams.categorySlug).success (data) ->
        $scope.loading = false
        console.log('ji')
        $scope.publicCollections = data.public_collections.map (e) ->
          new CollectionFactory(e)
        $scope.privateCollections = data.private_collections.map (e) ->
          new CollectionFactory(e)
        $scope.category = data.category
        $scope.allCollections = $scope.publicCollections.concat $scope.privateCollections
        if slug == 'public' or slug == 'all'
          $scope.allCollections = $scope.publicCollections
        else
          $scope.allCollections = $scope.privateCollections

  $timeout ->
    if CurrentUserFactory.serverSideLoggedIn()
      CurrentUserFactory.getCurrentUser().success (data) ->
        if data.success
          $scope.currentUser = data


    if $routeParams.categorySlug
      $scope.loadCategory($routeParams.categorySlug)


CollectionsBrowseController.$inject = [
  "$scope"
  "$location"
  "$routeParams"
  "$timeout"
  "CurrentUserFactory"
  "CollectionFactory"
  "CollectionCategoriesFactory"
]

angular.module("meed").controller "CollectionsBrowseController", CollectionsBrowseController
