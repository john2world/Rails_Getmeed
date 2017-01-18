ComingSoonController = (
  $scope,
  $routeParams,
  UTILS,
  CONSTS,
  MeedApiFactory,
  HeaderNavFactory
  ) ->

  $scope.load = false
  school_id = $routeParams.school_id
  $scope.campaign_type = $routeParams.campaign_type
  campaign_type= $routeParams.campaign_type
  HeaderNavFactory.setBgHidden(true)
  MeedApiFactory.get("ineedmeed/?school_id=#{school_id}&campaign_type=#{campaign_type}").success (data) ->
    if data.success
      $scope.school = data.school
    $scope.load = true

  $scope.universityEmailPattern = CONSTS.university_email_pattern
  HeaderNavFactory.setHidden(true)
  UTILS.setPageTitle("Meed - I Need Meed")

  $scope.join = (formData, isValid = true) ->
    return unless isValid
    url = "/ineedmeed/?email=#{formData.university_email}&referrer=#{$routeParams.referrer}&school_id=#{school_id}&campaign_type=#{campaign_type}"
    UTILS.redirect(url)

ComingSoonController.$inject = [
  "$scope"
  "$routeParams"
  "UTILS"
  "CONSTS"
  "MeedApiFactory"
  "HeaderNavFactory"
]

angular.module("meed").controller "ComingSoonController", ComingSoonController
