searchResults = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/core/search-results.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->
      # $("document").on "click", "a.result", ->
      #   $("#hits").hide()


searchResults.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "searchResults", searchResults
