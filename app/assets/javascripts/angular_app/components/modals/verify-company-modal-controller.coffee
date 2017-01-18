angular.module("meed").controller "VerifyCompanyModalController", [
  '$scope', 'close', 'MeedApiFactory',
  ($scope, close, MeedApiFactory) ->
    $scope.submit = ->
      MeedApiFactory.post(
        url: "/company/verify"
        data:
          email: $scope.email
      ).success((data) ->
        $scope.valid_email = true
      ).error( (data) ->
        $scope.errors = data.errors
      )
]
