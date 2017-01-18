profileResumeUpload = (CONSTS, VENDOR, $timeout, $route, ProfileFactory, CurrentUserFactory) ->
  ctrl = ($scope) ->
    onResumeUpload = () ->
      data = {
        resume_url: $scope.resume_url
      }
      ProfileFactory.uploadResumeFile(data).success (data) ->
        if data.success
          $route.reload();
          CurrentUserFactory.updateCurrentUser($scope)

    $scope.onResumeUpload = onResumeUpload
    $scope.filepickerApiKey = CONSTS.filepicker_api_key


  ctrl.$inject = [
    "$scope"
  ]


  return {
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-resume-upload.html"
  replace: false
  scope: {
    profile: "="
  }
  controller: ctrl

  }





profileResumeUpload.$inject = [
  "CONSTS"
  "VENDOR"
  "$timeout"
  "$route"
  "ProfileFactory"
  "CurrentUserFactory"
]

angular.module("meed").directive "profileResumeUpload", profileResumeUpload
