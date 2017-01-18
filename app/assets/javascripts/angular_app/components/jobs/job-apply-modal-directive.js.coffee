jobApplyModal = (CONSTS, UTILS, $timeout, $window, JobFactory, ActivityFeedItemFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/jobs/job-apply-modal.html"
  replace: false
  scope: {
    currentUser: "="
    job: "="
    tags:"="
    allCollections:"="
  }
  link: ($scope, elem, attrs) ->

    showStep = (step) ->
      $("\#job-apply-modal .step").hide()
      $("\#job-apply-modal .step.#{step}").show()
      $closestModal = $("#job-apply-modal").closest(".modal")
      if $closestModal.length == 0
        UTILS.center($("#job-apply-modal"))
        $.modal.resize()
        $(window).resize ->
          UTILS.center($("#job-apply-modal"))
          $.modal.resize()
      else
        $.modal.resize()

      $timeout ->
        UTILS.center($("#job-apply-modal"))
        $.modal.resize()

    resetFormData = () ->
      $scope.showCoverNoteForm = false
      $scope.applyFormData = {
        description: {
          text: null
        }
        cover_description: {
          text: null
        }
        code_description: {
          text: null
        }
      }

    $scope.$watch (($scope) ->
      $scope.job
    ), (newValue, oldValue) ->
      resetFormData()

    $(document).on "click", ".open-covernote-form", ->
      $timeout ->
        $scope.showCoverNoteForm = !$scope.showCoverNoteForm
        if !$scope.showCoverNoteForm
          $scope.applyFormData.cover_description.text = null

    $timeout ->
      # default step is apply and modal should be closed
      showStep("apply")
      UTILS.closeModal()
      elem.find(".close-modal").click ->
        UTILS.closeModal()
        resetFormData()

      elem.find(".update-profile").click ->
        UTILS.closeModal()

    $scope.submitApply = (id) ->
      JobFactory.applyJob(id, $scope.applyFormData).success (data) ->
        console.log(id)
        $window.Intercom('trackEvent', 'js-apply-job', {job_id: id})
        # wait for 0.5 secs to run update
        setTimeout ->
          $window.Intercom('update')
        , 500

        # TODO: do something with the returned jobs list ?
        #UTILS.closeModal()
        if data.success
          $scope.job.applied = true
          $scope.recommended_jobs = data.recommended_jobs
          showStep('confirmation')


jobApplyModal.$inject = [
  "CONSTS"
  "UTILS"
  "$timeout"
  "$window"
  "JobFactory"
  "ActivityFeedItemFactory"
]

angular.module("meed").directive "jobApplyModal", jobApplyModal
