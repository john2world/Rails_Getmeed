collectionForm = ($timeout, CONSTS, VENDOR) ->

  ctrl = ($scope) ->
    $scope.filepickerApiKey = CONSTS.filepicker_api_key

  ctrl.$inject = [
    "$scope"
  ]

  linkFn = ($scope, elem, attrs) ->
    $("#cover-image-input").change ->
      $scope.$apply()
    $timeout ->



  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/collections/collection-form.html"
    replace: true
    controller: ctrl
    link: linkFn
  }

collectionForm.$inject = [
  "$timeout"
  "CONSTS"
  "VENDOR"
]

angular.module("meed").directive "collectionForm", collectionForm
