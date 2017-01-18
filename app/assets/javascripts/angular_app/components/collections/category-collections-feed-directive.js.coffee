categoryCollectionsFeed = ($timeout, CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/collections/category-collections-feed.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->
      # Do stuff

categoryCollectionsFeed.$inject = [
  "$timeout"
  "CONSTS"
]

angular.module("meed").directive "categoryCollectionsFeed", categoryCollectionsFeed
