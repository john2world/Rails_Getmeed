feedItemSocialShareModal = ($timeout, $routeParams, CONSTS, UTILS) ->
  linkFn = ($scope, elem, attrs) ->
    $timeout ->
      if $scope.open
        UTILS.openModal "#feed-item-social-share-modal", {
          overlay:     false
          escapeClose: false
          clickClose:  false
          showSpinner: false
          showClose:   false
        }



  return {
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/dashboard/activity-feed/feed-item-social-share-modal.html"
  replace: true
  scope: {
    item: "="
    ownSubmission: "@"
  }
  link: linkFn
  }

feedItemSocialShareModal.$inject = [
  "$timeout"
  "$routeParams"
  "CONSTS"
  "UTILS"
]

angular.module("meed").directive "feedItemSocialShareModal", feedItemSocialShareModal
