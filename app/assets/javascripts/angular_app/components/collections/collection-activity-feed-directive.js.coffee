collectionActivityFeed = ($timeout,
                          $routeParams,
                          CONSTS,
                          HorizontalFeedUiFactory
                          ActivityFeedFactory,
                          ActivityFeedItemFactory,
                          CollectionsFactory) ->


  ctrl = ($scope) ->
    $scope.page = 2
    $scope.pageSize = 7
    $scope.scroll_fetching = false
    $scope.scroll_disabled = false
    collectionId = $routeParams.collectionId
    slugId = $routeParams.slugId
    $scope.getMore = ->
      if $scope.scroll_fetching == true
        return
      $scope.scroll_fetching = true
      if $scope.fromTag == 'true'
        ActivityFeedFactory.getFeedForTag($scope.tagId, $scope.page++, $scope.pageSize).success (data) ->
          $scope.scroll_fetching = false
          if data.feed_items && data.feed_items.length > 0
            feedItems = data.feed_items.map((e) ->
              new ActivityFeedItemFactory(e)
            )
            i = 0
            while i < feedItems.length
              $scope.feedItems.push feedItems[i]
              i++
          else
            $scope.scroll_disabled = true
      else
        CollectionsFactory.getCollectionFull(slugId, collectionId, $scope.page++, $scope.pageSize).success (data) ->
          $scope.scroll_fetching = false
          if data.feed_items && data.feed_items.length > 0
            feedItems = data.feed_items.map( (e) ->
              new ActivityFeedItemFactory(e)
            )
            i = 0
            while i < feedItems.length
              $scope.feedItems.push feedItems[i]
              i++
            $scope.loading = false
          else
            $scope.scroll_disabled = true

  ctrl.$inject = [
    "$scope"
  ]

  linkFn = ($scope, elem, attrs) ->
    $timeout ->
      outerWrapSelector = "#category-collections-feed .horizontal-feed-outer-wrap"
      HorizontalFeedUiFactory.initScrollOnHover(outerWrapSelector)

      $scope.title = () ->
        if $scope.titleOverride
          return $scope.titleOverride
        else if $scope.category
          return $scope.category.title
        else
          return "All"


  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/collections/collection-activity-feed.html"
    replace: false
    scope: {
      feedItems: "="
      category: "="
      titleOverride: "@"
      noFeedItems: "="
      fromTag: "@"
      tagId: "="
      allCollections: "="
      tags: "="
    }
    controller: ctrl
    link: linkFn
  }

collectionActivityFeed.$inject = [
  "$timeout"
  "$routeParams"
  "CONSTS"
  "HorizontalFeedUiFactory"
  "ActivityFeedFactory"
  "ActivityFeedItemFactory"
  "CollectionsFactory"
]

angular.module("meed").directive "collectionActivityFeed", collectionActivityFeed
