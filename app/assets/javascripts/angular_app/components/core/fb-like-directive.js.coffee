fbLike = ($timeout, CONSTS, FacebookFactory) ->

  return {
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/core/fb-like.html"
  replace: true

  link: ($scope, elem, attrs) ->

  }

fbLike.$inject = [
  "$timeout"
  "CONSTS"
  "FacebookFactory"
]

angular.module("meed").directive "fbLike", fbLike
