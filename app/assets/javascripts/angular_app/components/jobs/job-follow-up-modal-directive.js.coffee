jobFollowUpModal = (CONSTS, UTILS, $timeout, JobFollowupFactory) ->

  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/jobs/job-follow-up-modal.html"
  scope: {
    company: "="
    hash: "="
  }
  replace: true
  link: ($scope, elem, attrs) ->

    $(document).on "click", ".open-job-follow-up-modal", ->
      $this = $(this)
      $scope.company = $this.data("job-company")
      $scope.hash = $this.data("job-hash")
      $scope.$apply()
      UTILS.openModal("#job-follow-up-modal")

    clearFollowUpForm = () ->
      $("#job-follow-up-form")[0].reset()
      $scope.submitted = false
      $scope.jobFollowUpForm.$setPristine();

    submitFollowUp = (valid = false) ->
      return false unless valid
      $scope.submitted = true
      data    = $scope.formData
      data.id = $scope.hash
      success = () ->
        # TODO: something to indicate that you followed up
        $.modal.close()
      JobFollowupFactory.submitFollowUp(data, success)

    $scope.submitFollowUp = submitFollowUp

    $timeout ->
      elem.find(".close-modal").click -> $.modal.close()
      elem.on $.modal.BEFORE_CLOSE, (event, modal) ->
        clearFollowUpForm()


jobFollowUpModal.$inject = [
  "CONSTS"
  "UTILS"
  "$timeout"
  "JobFollowupFactory"
]

angular.module("meed").directive "jobFollowUpModal", jobFollowUpModal
