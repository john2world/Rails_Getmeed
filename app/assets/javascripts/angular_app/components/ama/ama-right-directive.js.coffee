amaRight = ($timeout, $routeParams, CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/ama/ama-right.html"
  replace: true
  scope: {
    currentUser: "="
    ama: "="
    loadAma: "="
  }

  link: ($scope, elem, attrs) ->

amaRight.$inject = [
  "$timeout"
  "$routeParams"
  "CONSTS"
]

angular.module("meed").directive "amaRight", amaRight
