requireCompany = ($timeout, ModalService, CONSTS) ->
  restrict: "A"
  scope:
    currentUser: "="

  link: ($scope, element, attrs) ->
    element.on 'click', (e) ->
      unless $scope.currentUser.verified_current_company
        e.preventDefault()
        ModalService.showModal(
          templateUrl: "#{CONSTS.components_dir}/modals/verify-company-modal.html",
          controller: "VerifyCompanyModalController"
        ).then((modal) ->
          modal.element.modal()
          modal.close.then((confirmed) ->
            $.modal.close()
          )
        )

requireCompany.$inject = [
  "$timeout"
  "ModalService"
  "CONSTS"
]

angular.module("meed").directive "requireCompany", requireCompany
