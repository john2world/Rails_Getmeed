jobSingle = (CONSTS, UTILS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/jobs/job-single.html"
  replace: true
  scope: {
    job: "="
    currentUser: "="
    metadata: "="
  }
  # controller: ($scope) ->
  link: ($scope, elem, attrs) ->
    $timeout ->
      if $scope.currentUser
        elem.find(".open-job-apply-modal").click ->

          UTILS.openModal "#job-apply-modal"
      else
        elem.find(".open-job-apply-modal").click ->
          UTILS.openModal "#signup-modal", {
            overlay:     false
            escapeClose: false
            clickClose:  false
            showSpinner: false
            showClose:   false
          }
      $("abbr.timeago").timeago()
      $scope.getTextImagePlaceholder = UTILS.getTextImagePlaceholder
      $scope.generateCompensationText = (job) ->
        if job.type == 'Mini Internship (Fixed)'

          if job.fixed_compensation > 0
            return "$#{job.fixed_compensation}"
          else
            return "$"
        else if job.type == 'Mini Internship (Hourly)'
          if job.hourly_compensation > 0
            return "$#{job.hourly_compensation}/hr"
          else
            return "$"
        else
          return "$"


jobSingle.$inject = [
  "CONSTS"
  "UTILS"
  "$timeout"
]

angular.module("meed").directive "jobSingle", jobSingle
