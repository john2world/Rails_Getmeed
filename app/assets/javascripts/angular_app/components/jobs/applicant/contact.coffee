angular.module("meed").controller "ModalsJobContact", ['$scope', 'applicant', 'close', 'MeedApiFactory',
  ($scope, applicant, close, MeedApiFactory) ->
    $scope.applicant = applicant
    $scope.close = (result) ->
      if result
        data =
          subject: $scope.subject
          description: $scope.description
          job_id: $scope.applicant.job._id
          handle: $scope.applicant.handle
        MeedApiFactory.post(url: '/user_messages', data: data).success (data) ->
          console.log data
      close(result)
]
