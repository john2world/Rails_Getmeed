LegalController = ($scope, CONSTS, UTILS, MeedApiFactory) ->
  $scope.item = {
    email: ""

    body: {
      text: ""
    }
  }
  $scope.show = true

  UTILS.setPageTitle("Legal Terms of Service")

LegalController.$inject = [
  "$scope"
  "CONSTS"
  "UTILS"
  "MeedApiFactory"
]

angular.module("meed").controller "LegalController", LegalController
