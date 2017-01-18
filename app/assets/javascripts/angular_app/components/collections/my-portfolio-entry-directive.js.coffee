myPortfolioEntry = ($timeout, CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/collections/my-portfolio-entry.html"
  replace: true

  link: ($scope, elem, attrs) ->
    $timeout ->


myPortfolioEntry.$inject = [
  "$timeout"
  "CONSTS"
]

angular.module("meed").directive "myPortfolioEntry", myPortfolioEntry
