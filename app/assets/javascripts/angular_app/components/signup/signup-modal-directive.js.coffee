signupModal = ($timeout, $routeParams, CONSTS, UTILS) ->
  linkFn = ($scope, elem, attrs) ->
    $timeout ->
      if $routeParams.oauth_token || $scope.open
        UTILS.openModal "#signup-modal", {
          overlay:     false
          escapeClose: false
          clickClose:  false
          showSpinner: false
          showClose:   false
        }





  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/signup/signup-modal.html"
    replace: true
    scope: {
      open: "="
    }
    link: linkFn
  }

signupModal.$inject = [
  "$timeout"
  "$routeParams"
  "CONSTS"
  "UTILS"
]

angular.module("meed").directive "signupModal", signupModal
