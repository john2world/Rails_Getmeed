categoriesFeed = ($timeout, CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/collections/categories/categories-feed.html"
  replace: true
  scope: {
    currentUser: "="
    publicCollections: "="
    privateCollections: "="
    category: "="
    loadCategory: "="
  }
  link: ($scope, elem, attrs) ->
    $timeout ->



categoriesFeed.$inject = [
  "$timeout"
  "CONSTS"
]

angular.module("meed").directive "categoriesFeed", categoriesFeed
