activityFeed = ($timeout, CONSTS, UTILS, ActivityFeedFactory, ActivityFeedItemFactory) ->

  ctrl = ($scope) ->
    $scope.page = 2
    $scope.pageSize = 5
    $scope.scroll_fetching = false
    $scope.scroll_disabled = false
    $scope.getMore = ->
      if $scope.scroll_fetching == true
         return
      $scope.scroll_fetching = true
      handleFeedResponse = (data) ->
        $scope.scroll_fetching = false
        if data.feed.length > 0
          feedItems = data.feed.map( (e) ->
            new ActivityFeedItemFactory(e)
          )

          i = 0

          if !$scope.feedItems
            $scope.feedItems

          while i < feedItems.length
            $scope.feedItems.push feedItems[i]
            i++
        else
          $scope.scroll_disabled = true

      if $scope.schoolFilter
        ActivityFeedFactory.getUniversityFeedForPage($scope.page++, $scope.pageSize).success handleFeedResponse
      else
        ActivityFeedFactory.getFeedForPage($scope.page++, $scope.pageSize).success handleFeedResponse

    $scope.$on "deletedItem", (event, item) ->
      UTILS.removeItemFromList(item, $scope.feedItems)

  ctrl.$inject = [
    "$scope"
  ]


  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/dashboard/activity-feed/activity-feed.html"
    scope: {
      hasFeedItems: "="
      feedItems: "="
      allCollections: "="
      tags: "="
      schoolFilter: "="
    }
    controller: ctrl
    link: ($scope, elem, attrs) ->
      $timeout ->

  }
  # http://stackoverflow.com/questions/15672709/how-to-require-a-controller-in-an-angularjs-directive

activityFeed.$inject = [
  "$timeout"
  "CONSTS"
  "UTILS"
  "ActivityFeedFactory"
  "ActivityFeedItemFactory"
]

angular.module("meed").directive "activityFeed", activityFeed
