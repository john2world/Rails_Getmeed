meedpostRequest = ($timeout, CONSTS, MeedApiFactory) ->

  linkFn = ($scope, elem, attrs) ->

  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/meedpost/meedpost-request.html"
    replace: true
    link: linkFn
  }

meedpostRequest.$inject = [
  "$timeout"
  "CONSTS"
  "MeedApiFactory"
]

angular.module("meed").directive "meedpostRequest", meedpostRequest
