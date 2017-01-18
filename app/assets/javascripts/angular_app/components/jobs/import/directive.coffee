jobImport = (CONSTS, MeedApiFactory) ->
  ctrl = ($scope) ->
    $scope.importJob = (valid) ->
      return unless valid

      MeedApiFactory.post(url: "/jobs/import", data: { url: $scope.importUrl }).success (data) ->
        $scope.job.title = data.title
        $scope.job.description = data.description

  ctrl.$inject = [
    "$scope"
  ]

  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/jobs/import/view.html"
    replace: false
    scope:
      job: "="
    controller: ctrl
  }

jobImport.$inject = [
  "CONSTS"
  "MeedApiFactory"
]

angular.module("meed").directive "jobImport", jobImport
