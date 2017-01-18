recommendedCollections = ($timeout, CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/collections/recommended-collections.html"
  replace: true
  controller: "RecommendedCollectionsController"
  link: ($scope, elem, attrs) ->
    $timeout ->
      # Do stuff

recommendedCollections.$inject = [
  "$timeout"
  "CONSTS"
]

angular.module("meed").directive "recommendedCollections", recommendedCollections
