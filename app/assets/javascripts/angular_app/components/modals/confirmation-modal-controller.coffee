angular.module("meed").controller "ConfirmationModalController", ['$scope', 'close', ($scope, close) ->
  $scope.close = (result) ->
    close(result)
]
