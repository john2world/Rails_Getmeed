tagNav = ($timeout, CONSTS, CollectionFactory, ProfileFactory) ->

  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/core/tag-nav.html"
  scope: {
    trendingTags: "="
  }
  replace: true

  link: ($scope, elem, attrs) ->
    $timeout ->
      ProfileFactory.getUserRecommendations().success (data) ->
        if data.recommended_users
          $scope.recommendedUsers = data.recommended_users.slice(0, 20)



tagNav.$inject = [
  "$timeout"
  "CONSTS"
  "CollectionFactory"
  "ProfileFactory"
]

angular.module("meed").directive "tagNav", tagNav
