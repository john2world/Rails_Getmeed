SettingsController = ($scope, UTILS, CurrentUserFactory, SettingsFactory) ->

  CurrentUserFactory.getCurrentUser().success (data) ->
    if data.success
      $scope.currentUser = data
    else
      $scope.currentUser = null

  SettingsFactory.getSettings().success (data) ->
    $scope.settings = data

  $scope.openDeactivateAccountModal = () ->
    UTILS.openModal("#deactivate-account-modal")

  $scope.saveSettings = () ->
    handle = $scope.currentUser.handle
    settings = $scope.settings
    SettingsFactory.saveSettings(handle, settings).success (data) ->
      if data.redirect_url
        UTILS.redirect data.redirect_url
      if data.message
        $scope.message = data.message
        $(".alert.success").show()
        setTimeout ->
          $(".alert.success").slideUp()
        , 3000


  $scope.deactivateSurvey = {}
  $scope.deactivateAccount = () ->
    SettingsFactory.deactivateAccount($scope.deactivateSurvey).success (data) ->
      if data.success
        $scope.settings.deactivate = true
        $scope.saveSettings()

  UTILS.setPageTitle("Account Settings")

SettingsController.$inject = [
  "$scope"
  "UTILS"
  "CurrentUserFactory"
  "SettingsFactory"
]

angular.module("meed").controller "SettingsController", SettingsController
