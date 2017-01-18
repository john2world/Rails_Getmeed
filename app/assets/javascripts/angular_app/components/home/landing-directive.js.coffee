# Expects item to be passed in with id, url, title
landing = (CONSTS, $routeParams, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/home/landing.html"
  replace: false
  link: ($scope, elem, attrs) ->
    $timeout ->
      $scope.ab_test = false
      if $routeParams.referrer == 'fb_resume_review'
        $scope.ab_test_header = 'Happy Thanksgiving!'
        $scope.ab_test_sub_heading = 'We Are Reviewing All New Profiles On Meed!'
        $scope.ab_test = true



landing.$inject = [
  "CONSTS"
  "$routeParams"
  "$timeout"
]

angular.module("meed").directive "landing", landing
