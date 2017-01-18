loader = (CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/core/loader.html"
  replace: true

loader.$inject = [
  "CONSTS"
]

angular.module("meed").directive "loader", loader
