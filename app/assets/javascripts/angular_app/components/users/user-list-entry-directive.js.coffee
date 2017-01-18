userListEntry = ($timeout, CONSTS, ProfileFactory, HorizontalFeedUiFactory) ->

  ctrl = ($scope) ->
    user = $scope.user
    if user.badge == 'influencer'
      $scope.afterFollowText = 'Ask A Question'

    $scope.follow = () ->
      ProfileFactory.followUser(user.handle, $scope.source).success (data) ->
        $scope.user.is_viewer_following = true

    $scope.invite = () ->
      ProfileFactory.inviteLead(user.email, $scope.source).success (data) ->
        $scope.user.is_user_invited = true

    $scope.unfollow = () ->
      ProfileFactory.unfollowUser(user.handle, $scope.source).success (data) ->
        $scope.user.is_viewer_following = false

  ctrl.$inject = [
    "$scope"
  ]


  linkFn = ($scope, elem, attrs) ->
    $timeout ->
      feedItemSelector = "user-list-entry"
      innerWrapSelector = "#category-user-feed .horizontal-feed-inner-wrap"
      HorizontalFeedUiFactory.setInnerWrapWidth(feedItemSelector, innerWrapSelector)

  return {
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/users/user-list-entry.html"
  replace: true
  scope: {
    user: "="
    currentUser: "="
    regFlow: "="
    source: "@"
  }
  controller: ctrl
  link: linkFn
  }

userListEntry.$inject = [
  "$timeout"
  "CONSTS"
  "ProfileFactory"
  "HorizontalFeedUiFactory"
]

angular.module("meed").directive "userListEntry", userListEntry
