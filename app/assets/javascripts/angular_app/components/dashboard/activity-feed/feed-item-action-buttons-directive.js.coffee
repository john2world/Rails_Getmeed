# Expects item to be passed in with id, url, title
feedItemActionButtons = (CONSTS, $timeout, ModalService) ->

  ctrl = ($scope) ->
    $scope.item.path = null if $scope.deactivateLinks

  ctrl.$inject = [
    "$scope"
  ]

  linkFn = ($scope, elem, attrs) ->
    $scope.currentUser = $scope.$parent.currentUser
    $scope.edit = ->
      $scope.$emit("editItem", $scope.item)

    $scope.del = ->
      ModalService.showModal(
        templateUrl: "#{CONSTS.components_dir}/modals/confirmation-modal.html",
        controller: "ConfirmationModalController"
      ).then((modal) ->
        modal.element.modal()
        modal.close.then((confirmed) ->
          $.modal.close()
          if confirmed
            $scope.item.delete -> $scope.$emit("deletedItem", $scope.item)
        )
      )

  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/dashboard/activity-feed/feed-item-action-buttons.html"
    replace: true
    scope: {
      item: "="
      deactivateLinks: "@"
    }
    controller: ctrl
    link: linkFn
  }
feedItemActionButtons.$inject = [
  "CONSTS"
  "$timeout"
  "ModalService"
]

angular.module("meed").directive "feedItemActionButtons", feedItemActionButtons
