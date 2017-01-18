CompanyEditController = ($scope, $location, MeedApiFactory, CONSTS, VENDOR) ->
  $scope.submit = ->
    $scope.loading = true
    MeedApiFactory.post(url: "/company/update", data: $scope.company).success (data) ->
      $scope.loading = false
      $location.path 'jobs/new'

  MeedApiFactory.get("/company/edit").success (data) ->
    $scope.company = data.company

  $scope.filepickerApiKey = CONSTS.filepicker_api_key

CompanyEditController.$inject = [
  "$scope"
  "$location"
  "MeedApiFactory"
  "CONSTS"
  "VENDOR"
]

angular.module("meed").controller "CompanyEditController", CompanyEditController
