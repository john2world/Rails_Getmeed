# Expects comment to be passed in
comment = (CONSTS, CommentFactory, $timeout, ModalService) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/article/comment.html"
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
            $scope.comment.delete -> $scope.$emit("deletedComment", $scope.comment)
        )
      )

    $scope.keydown = (e)->
      if e.keyCode == 13 && e.shiftKey == false
        e.preventDefault()
        $scope.submitComment(this.commentForm.$valid)

    $scope.submitComment = (valid) ->
      return false unless valid
      CommentFactory.updateComment($scope.comment._id,
        description: $scope.comment.description
      ).success (data) ->
        $scope.comment.editing = false

    $timeout ->

comment.$inject = [
  "CONSTS"
  "CommentFactory"
  "$timeout"
  "ModalService"
]

angular.module("meed").directive "comment", comment
