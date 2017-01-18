CollectionCategoriesController = ($scope, UTILS, CollectionCategoriesFactory, CurrentUserFactory) ->
  # $scope.collectionCategories = CollectionCategoriesFactory.fixed()
  if CurrentUserFactory.serverSideLoggedIn()
    CurrentUserFactory.getCurrentUser().success (data) ->
      if data.success
        $scope.currentUser = data

  UTILS.setPageTitle("Collection Categories")


CollectionCategoriesController.$inject = [
  "$scope"
  "UTILS"
  "CollectionCategoriesFactory"
  "CurrentUserFactory"
]

angular.module("meed").controller "CollectionCategoriesController", CollectionCategoriesController
