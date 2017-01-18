rulesModal = ($timeout, $routeParams, CONSTS, UTILS) ->
  linkFn = ($scope, elem, attrs) ->
    $timeout ->





  return {
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/dashboard/rules-modal.html"
  replace: true
  scope: {
    open: "="
  }
  link: linkFn
  }

rulesModal.$inject = [
  "$timeout"
  "$routeParams"
  "CONSTS"
  "UTILS"
]

angular.module("meed").directive "rulesModal", rulesModal
