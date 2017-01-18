# Expects item to be passed in with id, comments
reviewInvites = (CONSTS, UTILS, MeedApiFactory, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/review-invites.html"
  replace: true
  scope: {
    item: "="
    currentUser: "="
    invites: "="
    addReference: "="
  }
  link: ($scope, elem, attrs) ->
    reviews_url = "/profiles/course/invites/#{$scope.item._id}"
    $scope.invites = []
    MeedApiFactory.get(reviews_url).success (data) ->
      if data.success
        $scope.invites = data.invites

    $scope.addReference = () ->
      new_invite = {new: true, course_id: $scope.item._id}
      $scope.invites.push(new_invite)

reviewInvites.$inject = [
  "CONSTS"
  "UTILS"
  "MeedApiFactory"
  "$timeout"
]

angular.module("meed").directive "reviewInvites", reviewInvites
