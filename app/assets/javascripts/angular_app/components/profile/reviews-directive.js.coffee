# Expects item to be passed in with id, comments
reviews = (CONSTS, UTILS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/reviews.html"
  replace: true
  scope: {
    item: "="
    currentUser: "="
    showAll: '='
  }
  link: ($scope, elem, attrs) ->
    $scope.showAll = false
    $scope.showReviews = (val) ->
      $scope.showAll = val

    $scope.$on "deletedComment", (event, comment) ->
      UTILS.removeItemFromList(comment, $scope.item.comments)

reviews.$inject = [
  "CONSTS"
  "UTILS"
  "$timeout"
]

angular.module("meed").directive "reviews", reviews
