signupProfilePicture = (CONSTS, VENDOR, $timeout, $route, ProfileFactory, CurrentUserFactory) ->
  ctrl = ($scope) ->
    $scope.filepickerApiKey = CONSTS.filepicker_api_key

  ctrl.$inject = [
    "$scope"
  ]

  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/signup/signup-profile-picture.html"
  replace: false
  scope:
    profile: "="
    formData: '='
  controller: ctrl

signupProfilePicture.$inject = [
  "CONSTS"
  "VENDOR"
  "$timeout"
  "$route"
  "ProfileFactory"
  "CurrentUserFactory"
]

angular.module("meed").directive "signupProfilePicture", signupProfilePicture
