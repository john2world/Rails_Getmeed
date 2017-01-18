signupForm = ($timeout, CONSTS) ->

  linkFn = ($scope, elem, attrs) ->
    # $timeout ->
    #   $(elem).find("select").selectize()

  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/signup/signup-form.html"
    replace: true
    controller: "SignupFormController"
    link: linkFn
  }

signupForm.$inject = [
  "$timeout"
  "CONSTS"
  "UTILS"
]

angular.module("meed").directive "signupForm", signupForm
