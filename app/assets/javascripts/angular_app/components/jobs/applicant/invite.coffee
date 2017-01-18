angular.module("meed").controller "ModalsJobInvite", ['$scope', 'applicant', 'currentUser', 'close', 'MeedApiFactory', ($scope, applicant, currentUser, close, MeedApiFactory) ->
  $scope.currentUser = currentUser
  $scope.subject = "Invitation to apply for a position #{currentUser.current_company}"
  $scope.description = "Hi \n I am  #{currentUser.name},  #{currentUser.headline} at #{currentUser.current_company}.  I saw your profile on Meed and interested to chat about the following opportunity. Please accept my invitation to apply and we can take it from there."
  $scope.close = (result) ->
    if result
      data =
        subject: $scope.subject
        description: $scope.description
        job_id: applicant.job._id
        handle: applicant.handle
      MeedApiFactory.post(url: "/job_applicants/#{applicant.id}/invite", data: data).success (job_applicant) ->
        console.log job_applicant
    close(result)
]
