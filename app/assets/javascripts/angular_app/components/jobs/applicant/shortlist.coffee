angular.module("meed").controller "ModalsJobShortlist", ['$scope', 'applicant', 'close', 'MeedApiFactory',
  ($scope, applicant, close, MeedApiFactory) ->
    MeedApiFactory.post(url: "/job_applicants/#{applicant.id}/shortlist").success (job_applicant) ->

    $scope.applicant = applicant
    $scope.close = (result) ->
      if result
        data =
          subject: $scope.subject
          description: $scope.description
          job_id: $scope.applicant.job._id
          handle: $scope.applicant.handle
        MeedApiFactory.post(url: '/user_messages', data: data)
      close(result)
]
