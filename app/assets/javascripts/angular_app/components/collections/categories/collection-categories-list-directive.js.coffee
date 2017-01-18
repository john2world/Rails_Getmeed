collectionCategoriesList = ($timeout, CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/collections/categories/collection-categories-list.html"
  replace: true
  scope: {
    privateCollections: "="
    publicCollections: "="
    currentUser: "="
    loadCategory: "="
    category: "="
  }
  link: ($scope, elem, attrs) ->
    $timeout ->

collectionCategoriesList.$inject = [
  "$timeout"
  "CONSTS"
]

angular.module("meed").directive "collectionCategoriesList", collectionCategoriesList
