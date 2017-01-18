hovercard = ($timeout, $compile) ->
  restrict: "A"
  scope:
    user: "="
    currentUser: "="

  link: ($scope, element, attrs) ->
    timer = null

    element.on 'mouseenter', ->
      if $scope.user.handle == $scope.currentUser.handle
        $scope.showHovercard = false
      else
        $scope.showHovercard = true

      tmpl = '<user-list-entry ng-if="showHovercard" user="user" current-user="currentUser"></user-list-entry>'
      element.append $compile(tmpl)($scope)

      $timeout.cancel timer if timer

    element.on 'mouseleave', ->
      timer = $timeout ->
        $scope.showHovercard = false
      , 50

hovercard.$inject = [
  "$timeout"
  "$compile"
]

angular.module("meed").directive "hovercard", hovercard
