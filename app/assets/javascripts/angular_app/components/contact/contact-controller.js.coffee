ContactController = ($scope, CONSTS, UTILS, MeedApiFactory) ->
  $scope.item = {
    email: ""

    body: {
      text: ""
    }
  }
  $scope.generalEmailPattern = CONSTS.general_email_pattern
  console.log()
  $scope.show = true

  $scope.showContactForm = () ->
    $scope.show

  $scope.submitContact = (isValid = false) ->
    data = $scope.item
    url = "/contactus"
    MeedApiFactory.post({data: data, url: url}).success (data) ->
      $scope.show = false
  UTILS.setPageTitle("Contact Us")

ContactController.$inject = [
  "$scope"
  "CONSTS"
  "UTILS"
  "MeedApiFactory"
]

angular.module("meed").controller "ContactController", ContactController
