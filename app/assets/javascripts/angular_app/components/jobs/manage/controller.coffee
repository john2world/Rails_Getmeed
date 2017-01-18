JobsManageController = ($scope, MeedApiFactory, ModalService, CONSTS, UTILS) ->
  $scope.scroll_fetching = true
  MeedApiFactory.get("/jobs/manage").success (jobs) ->
    $scope.scroll_fetching = false
    $scope.jobs = jobs

  $scope.edit = (job) ->
    $location.path "/jobs/#{job._id}/edit"

  $scope.toggle = (job) ->
    MeedApiFactory.put("/jobs/#{job._id}/toggle").success (data) ->
      job.live = data.job.live

  $scope.del = (job) ->
    ModalService.showModal(
      templateUrl: "#{CONSTS.components_dir}/modals/confirmation-modal.html",
      controller: "ConfirmationModalController"
    ).then((modal) ->
      modal.element.modal()
      modal.close.then((confirmed) ->
        $.modal.close()
        if confirmed
          MeedApiFactory.put("/jobs/#{job._id}/delete").success (data) ->
            UTILS.removeItemFromList(job, $scope.jobs)
      )
    )

JobsManageController.$inject = [
  "$scope"
  "MeedApiFactory"
  "ModalService"
  "CONSTS"
  "UTILS"
]

angular.module("meed").controller "JobsManageController", JobsManageController
