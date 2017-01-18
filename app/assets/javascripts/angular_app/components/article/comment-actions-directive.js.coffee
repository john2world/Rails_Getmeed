# Expects commentActions to be passed in
commentActions = (CONSTS, $timeout, CurrentUserFactory, ModalService) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/article/comment-actions.html"
  replace: true
  scope: {
    comment: "="
    currentUser: "="
  }
  link: ($scope, elem, attrs) ->
    $scope.del = ->
      ModalService.showModal(
        templateUrl: "#{CONSTS.components_dir}/modals/confirmation-modal.html",
        controller: "ConfirmationModalController"
      ).then((modal) ->
        modal.element.modal()
        modal.close.then((confirmed) ->
          $.modal.close()
          if confirmed
            $scope.comment.del ->
              $scope.$emit "deletedComment", $scope.comment
        )
      )

    $scope.edit = ->
      $scope.$emit("editComment", $scope.comment)

    if !$scope.currentUser
      CurrentUserFactory.getCurrentUser().success (data) ->
        if data.success
          $scope.currentUser = data


    $timeout ->


commentActions.$inject = [
  "CONSTS"
  "$timeout"
  "CurrentUserFactory"
  "ModalService"
]

angular.module("meed").directive "commentActions", commentActions
