angular.module("meed").controller "ModalsJobNote", ['$scope', 'applicant', 'close', 'MeedApiFactory',
  ($scope, applicant, close, MeedApiFactory) ->
    $scope.applicant = applicant
    $scope.close = (result) ->
      if result
        MeedApiFactory.put(url: "/job_applicants/#{applicant.id}", data: {job_applicant: $scope.applicant})
      close(result)
]
