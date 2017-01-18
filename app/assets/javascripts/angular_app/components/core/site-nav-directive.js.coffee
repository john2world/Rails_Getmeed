siteNav = ($timeout, $location, CONSTS, CurrentUserFactory, CollectionFactory, CollectionsFactory) ->

  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/core/site-nav.html"
  scope: {
    userCollections: "="
    trendingTags: "="
  }
  replace: true

  link: ($scope, elem, attrs) ->
    $timeout ->
    if CurrentUserFactory.serverSideLoggedIn()
      CurrentUserFactory.getCurrentUser().success (data) ->
        if data.success
          $scope.currentUser = data

siteNav.$inject = [
  "$timeout"
  "$location"
  "CONSTS"
  "CurrentUserFactory"
  "CollectionFactory"
  "CollectionsFactory"
]

angular.module("meed").directive "siteNav", siteNav
