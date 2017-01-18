collectionListEntry = ($timeout, CONSTS, HorizontalFeedUiFactory) ->

  ctrl = ($scope) ->
    collection = $scope.collection
    if $scope.userCollections
      collection.linkUrl = "/submit/post/#{collection._id}"
    else
      collection.linkUrl = "/collection/#{collection.slug_id}/#{collection._id}"

  ctrl.$inject = [
    "$scope"
  ]


  linkFn = ($scope, elem, attrs) ->
    $timeout ->
      feedItemSelector = "collection-list-entry"
      innerWrapSelector = "#category-collections-feed .horizontal-feed-inner-wrap"
      HorizontalFeedUiFactory.setInnerWrapWidth(feedItemSelector, innerWrapSelector)

  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/collections/collection-list-entry.html"
    replace: true
    scope: {
      collection: "="
      userCollections: "="
      currentUser: "="
      category: "="
    }
    controller: ctrl
    link: linkFn
  }

collectionListEntry.$inject = [
  "$timeout"
  "CONSTS"
  "HorizontalFeedUiFactory"
]

angular.module("meed").directive "collectionListEntry", collectionListEntry
