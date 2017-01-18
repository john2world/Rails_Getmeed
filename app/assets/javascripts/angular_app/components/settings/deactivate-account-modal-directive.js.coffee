deactivateAccountModal = ($timeout, CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/settings/deactivate-account-modal.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->
      # Do stuff

deactivateAccountModal.$inject = [
  "$timeout"
  "CONSTS"
]

angular.module("meed").directive "deactivateAccountModal", deactivateAccountModal
