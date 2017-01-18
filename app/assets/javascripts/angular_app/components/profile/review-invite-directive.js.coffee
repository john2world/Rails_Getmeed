# Expects item to be passed in with id, comments
reviewInvite = (CONSTS, UTILS, MeedApiFactory, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/review-invite.html"
  replace: true
  scope: {
    invite: "="
    index: "="
    course_id: '='
    remind: "="
  }
  link: ($scope, elem, attrs) ->
    $scope.remind = () ->
      url="/course/invite/#{$scope.invite._id}/remind"
      MeedApiFactory.get(url).success (data) ->
        if data.success
          $scope.invite.reminded = true
        else
          $scope.invite.reminded = false
    $scope.sendInvite = (invite, isValid) ->
      url = '/course/invite/'
      success = (data) ->
        if data.success
          $scope.invite = data.invite
          # update invites
          $scope.$parent.invites[$scope.index] = $scope.invite
      MeedApiFactory.post( url: url, data: invite, success: success )

    $scope.cancelReference = (invite) ->
      invites = $scope.$parent.$parent.invites
      index = invites.indexOf(invite)
      invites.splice(index, 1);

reviewInvite.$inject = [
  "CONSTS"
  "UTILS"
  "MeedApiFactory"
  "$timeout"
]

angular.module("meed").directive "reviewInvite", reviewInvite
