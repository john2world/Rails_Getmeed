companyListEntry = ($timeout, CONSTS, CompanyFactory, HorizontalFeedUiFactory) ->

  ctrl = ($scope) ->
    company = $scope.company

    $scope.follow = () ->
      CompanyFactory.follow(company._id).success (data) ->
        $scope.company.is_viewer_following = true

    $scope.unfollow = () ->
      CompanyFactory.unfollow(company._id).success (data) ->
        $scope.company.is_viewer_following = false

  ctrl.$inject = [
    "$scope"
  ]


  linkFn = ($scope, elem, attrs) ->
    $timeout ->
      feedItemSelector = "company-list-entry"
      innerWrapSelector = "#category-company-feed .horizontal-feed-inner-wrap"
      HorizontalFeedUiFactory.setInnerWrapWidth(feedItemSelector, innerWrapSelector)

  return {
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/company/company-list-entry.html"
  replace: true
  scope: {
    company: "="
    currentUser: "="
  }
  controller: ctrl
  link: linkFn
  }

companyListEntry.$inject = [
  "$timeout"
  "CONSTS"
  "CompanyFactory"
  "HorizontalFeedUiFactory"
]

angular.module("meed").directive "companyListEntry", companyListEntry
