angular.module("meed").controller "ModalsJobArchive", ['$scope', 'applicant', 'close', 'MeedApiFactory',
  ($scope, applicant, close, MeedApiFactory) ->
    $scope.applicant = applicant
    $scope.close = (confirmed) ->
      if confirmed
        MeedApiFactory.post(url: "/job_applicants/#{applicant.id}/archive", data: applicant)

      close(confirmed)
]
