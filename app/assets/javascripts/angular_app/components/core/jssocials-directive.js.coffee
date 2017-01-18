# Expects item to be passed in with id, url, title
jssocials = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/core/jssocials.html"
  replace: false
  scope: {
    item: "="
    titleOverride: "="
    urlOverride: "="

  }
  link: ($scope, elem, attrs) ->
    $timeout ->
      if $scope.item
        $scope.url = $scope.item.url
        $scope.title = $scope.item.title || $scope.item.caption

      $scope.url = $scope.urlOverride if $scope.urlOverride
      $scope.title = $scope.titleOverride if $scope.titleOverride
      $scope.mailto = "mailto:?subject=#{$scope.title}&body=#{$scope.url}"

jssocials.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "jssocials", jssocials
