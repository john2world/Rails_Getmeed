# Expects item to be passed in with id, url, title
feedUserActionButtons = (CONSTS, $timeout) ->

  ctrl = ($scope) ->
    $scope.item.path = null if $scope.deactivateLinks

  ctrl.$inject = [
    "$scope"
  ]

  linkFn = ($scope, elem, attrs) ->
    $scope.currentUser = $scope.$parent.currentUser


  return {
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/dashboard/activity-feed/feed-user-action-buttons.html"
  scope: {
    item: "="
    deactivateLinks: "@"
  }
  controller: ctrl
  link: linkFn
  }
feedUserActionButtons.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "feedUserActionButtons", feedUserActionButtons
