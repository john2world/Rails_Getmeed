# Expects comment to be passed in
review = (CONSTS, $timeout, ModalService) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/review.html"
  replace: true
  scope: {
    review: "="
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
              $scope.$emit("deletedComment", $scope.comment)
        )
      )

review.$inject = [
  "CONSTS"
  "$timeout"
  "ModalService"
]

angular.module("meed").directive "review", review
