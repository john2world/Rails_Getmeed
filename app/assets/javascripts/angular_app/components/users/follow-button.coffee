userFollowButton = (CONSTS, ProfileFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/users/follow-button.html"
  replace: false
  scope:
    user: '='
    currentUser: '='
    isFollowing: '='
  link: ($scope, elem, attrs) ->
    $scope.follow = () ->
      ProfileFactory.followUser($scope.user.handle).success (data) ->
        $scope.user.is_viewer_following = true
        $scope.isFollowing = true

    $scope.unfollow = () ->
      ProfileFactory.unfollowUser($scope.user.handle).success (data) ->
        $scope.user.is_viewer_following = false
        $scope.isFollowing = false

userFollowButton.$inject = [
  "CONSTS"
  "ProfileFactory"
]

angular.module("meed").directive "userFollowButton", userFollowButton
