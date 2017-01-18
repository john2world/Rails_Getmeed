profileImageEdit = (CONSTS, VENDOR, $timeout, $route, ProfileFactory, CurrentUserFactory) ->

  ctrl = ($scope) ->
    onPhotoUpload = () ->
      data = {
        user: {
          image_url: $scope.profile.user.image_url
        }
      }
      ProfileFactory.updateProfileImage(data).success (data) ->
        if data.success
          # reloading the entire page to render the image
          $route.reload();
          CurrentUserFactory.updateCurrentUser($scope)


    $scope.onPhotoUpload = onPhotoUpload
    $scope.filepickerApiKey = CONSTS.filepicker_api_key

  ctrl.$inject = [
    "$scope"
  ]


  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/profile/profile-image-edit.html"
    replace: false
    scope: {
      profile: "="
    }
    controller: ctrl

  }





profileImageEdit.$inject = [
  "CONSTS"
  "VENDOR"
  "$timeout"
  "$route"
  "ProfileFactory"
  "CurrentUserFactory"
]

angular.module("meed").directive "profileImageEdit", profileImageEdit
