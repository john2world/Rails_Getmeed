collectionCategories = ($timeout, CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/collections/categories/collection-categories.html"
  replace: true
  controller: "CollectionCategoriesController"
  link: ($scope, elem, attrs) ->
    $timeout ->
      # Do stuff

collectionCategories.$inject = [
  "$timeout"
  "CONSTS"
]

angular.module("meed").directive "collectionCategories", collectionCategories
