userBulkListEntry = ($timeout, CONSTS, ProfileFactory, HorizontalFeedUiFactory) ->

  ctrl = ($scope) ->
    user = $scope.user
    if user.badge == 'influencer'
      $scope.afterFollowText = 'Ask A Question'

    $scope.follow = () ->
      ProfileFactory.followUser(user.handle).success (data) ->
        $scope.user.is_viewer_following = true

    $scope.invite = () ->
      ProfileFactory.inviteLead(user.email).success (data) ->
        $scope.user.is_user_invited = true

    $scope.unfollow = () ->
      ProfileFactory.unfollowUser(user.handle).success (data) ->
        $scope.user.is_viewer_following = false

  ctrl.$inject = [
    "$scope"
  ]


  linkFn = ($scope, elem, attrs) ->
    timer = null
    $scope.onMouseEnter = ->
      $scope.showHovercard = true
      $timeout.cancel timer if timer
    $scope.onMouseLeave = ->
      timer = $timeout ->
        $scope.showHovercard = false
      , 200

    $timeout ->
      feedItemSelector = "user-list-entry"
      innerWrapSelector = "#category-user-feed .horizontal-feed-inner-wrap"
      HorizontalFeedUiFactory.setInnerWrapWidth(feedItemSelector, innerWrapSelector)

  return {
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/users/user-bulk-list-entry.html"
  replace: true
  scope: {
    user: "="
    currentUser: "="
    regFlow: "="
  }
  controller: ctrl
  link: linkFn
  }

userBulkListEntry.$inject = [
  "$timeout"
  "CONSTS"
  "ProfileFactory"
  "HorizontalFeedUiFactory"
]

angular.module("meed").directive "userBulkListEntry", userBulkListEntry
