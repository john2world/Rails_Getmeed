collectionCategoryListEntry = ($timeout, CONSTS, CurrentUserFactory, HorizontalFeedUiFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/collections/categories/collection-category-list-entry.html"
  replace: true
  scope: {
    publicCollections: "="
    privateCollections: "="
    currentUser: "="
    category: "="
    loadCategory: "="
  }
  link: ($scope, elem, attrs) ->
    $timeout ->
      if !$scope.currentUser && CurrentUserFactory.serverSideLoggedIn()
        CurrentUserFactory.getCurrentUser().success (data) ->
          if data.success
            $scope.currentUser = data

      $elem = $(elem)
      if $elem.closest(".collections-browse").length > 0
        # feedItemSelector = ".collection-category-list-entry"
        # innerWrapSelector = "#categories-feed .horizontal-feed-inner-wrap"
        # HorizontalFeedUiFactory.setInnerWrapWidth(feedItemSelector, innerWrapSelector)

        $(elem).find("a").click (event) ->
          event.preventDefault()
          $this = $(this)
          $scope.loadCategory($this.data("cat-id"))
          false

collectionCategoryListEntry.$inject = [
  "$timeout"
  "CONSTS"
  "CurrentUserFactory"
  "HorizontalFeedUiFactory"
]

angular.module("meed").directive "collectionCategoryListEntry", collectionCategoryListEntry
