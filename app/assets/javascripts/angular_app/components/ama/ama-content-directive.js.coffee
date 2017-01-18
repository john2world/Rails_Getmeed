amaContent = ($timeout, $routeParams, CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/ama/ama-content.html"
  replace: true
  scope: {
    currentUser: "="
    ama: "="
    loadAma: "="
  }

  link: ($scope, elem, attrs) ->
    $timeout ->
      if !($scope.ama && $scope.ama.comments && $scope.ama.comments.length > 0)
        $scope.loadAma($routeParams.ama_id)

amaContent.$inject = [
  "$timeout"
  "$routeParams"
  "CONSTS"
]

angular.module("meed").directive "amaContent", amaContent
