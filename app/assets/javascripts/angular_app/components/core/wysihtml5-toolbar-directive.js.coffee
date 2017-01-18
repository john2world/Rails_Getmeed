wysihtml5Toolbar = ($timeout, CONSTS, WysihtmlFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/core/wysihtml5-toolbar.html"
  replace: false
  scope: {
    wysihtml5ToolbarId: "@"
    wysihtml5TextareaId: "@"
  }
  link: ($scope, elem, attrs) ->
    $timeout ->
      # Set up wysiwyg!

      $textarea = $("##{$scope.wysihtml5TextareaId}")

      $closestModal = $textarea.closest(".modal")

      if $closestModal.length > 0
        jQuery ->
          $closestModal.on $.modal.OPEN, (event, modal) ->
            WysihtmlFactory.initWysihtml($scope.wysihtml5TextareaId, $scope.wysihtml5ToolbarId)

          $closestModal.on $.modal.CLOSE, (event, modal) ->
            WysihtmlFactory.destroyWysihtml($textarea)
      else
        WysihtmlFactory.initWysihtml($scope.wysihtml5TextareaId, $scope.wysihtml5ToolbarId)

wysihtml5Toolbar.$inject = [
  "$timeout"
  "CONSTS"
  "WysihtmlFactory"
]

angular.module("meed").directive "wysihtml5Toolbar", wysihtml5Toolbar
