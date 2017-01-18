portfolioActivityFeed = ($timeout, $location, CONSTS, HorizontalFeedUiFactory, UTILS) ->

  linkFn = ($scope, elem, attrs) ->
    $timeout ->
      outerWrapSelector = "#category-collections-feed .horizontal-feed-outer-wrap"
      HorizontalFeedUiFactory.initScrollOnHover(outerWrapSelector)
    $scope.$on "editItem", (event, item) ->
      $location.path "/stories/#{item.subject_id}/edit" if item.type == 'native_story'

    $scope.$on "deletedItem", (event, item) ->
      UTILS.removeItemFromList(item, $scope.feedItems)

  return {
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/collections/portfolio-activity-feed.html"
  replace: false
  scope: {
    feedItems: "="
    category: "="
    titleOverride: "@"
    noFeedItems: "="
    profile: "="
  }
  link: linkFn
  }

portfolioActivityFeed.$inject = [
  "$timeout"
  "$location"
  "CONSTS"
  "HorizontalFeedUiFactory"
  "UTILS"
]

angular.module("meed").directive "portfolioActivityFeed", portfolioActivityFeed
