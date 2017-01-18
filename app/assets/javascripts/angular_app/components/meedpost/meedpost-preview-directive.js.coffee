meedpostPreview = (CONSTS) ->

  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/meedpost/meedpost-preview.html"
    replace: true
    link: null
  }

meedpostPreview.$inject = [
  "CONSTS"
]

angular.module("meed").directive "meedpostPreview", meedpostPreview
