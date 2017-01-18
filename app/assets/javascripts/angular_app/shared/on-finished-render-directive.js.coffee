# http://stackoverflow.com/questions/15207788/calling-a-function-when-ng-repeat-has-finished#answer-15208347

onFinishRender = ($timeout, CONSTS) ->
  restrict: 'A'
  link: ($scope, element, attr) ->
    if $scope.$last == true
      $timeout ->
        $scope.$emit 'ngRepeatFinished'

onFinishRender.$inject = [
  "$timeout"
  "CONSTS"
]

angular.module("meed").directive "onFinishRender", onFinishRender
