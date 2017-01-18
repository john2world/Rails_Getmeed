jobCategoryListEntry = ($timeout, CONSTS, HorizontalFeedUiFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/jobs/job-category-list-entry.html"
  replace: true
  scope: {
    cat: "="
    loadCategory: "="
  }
  link: ($scope, elem, attrs) ->
    $timeout ->
      $elem = $(elem)
      if $elem.closest(".jobs-browse").length > 0
# feedItemSelector = ".job-category-list-entry"
# innerWrapSelector = "#categories-feed .horizontal-feed-inner-wrap"
# HorizontalFeedUiFactory.setInnerWrapWidth(feedItemSelector, innerWrapSelector)

        $(elem).find("a").click (event) ->
          event.preventDefault()
          $this = $(this)
          $scope.loadCategory($this.data("cat-id"))
          false

jobCategoryListEntry.$inject = [
  "$timeout"
  "CONSTS"
  "HorizontalFeedUiFactory"
]

angular.module("meed").directive "jobCategoryListEntry", jobCategoryListEntry
