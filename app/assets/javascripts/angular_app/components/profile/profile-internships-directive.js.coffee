profileInternships = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-internships.html"
  replace: false
  scope: {
    profile: "="
    fns: "="
    months: "="
    years: "="
  }
  # controller: ($scope) ->
  #   $scope.profile = $scope.$parent.profile
  #   $scope.fns = $scope.$parent.internshipFns
  #   console.log $scope.fns

  link: ($scope, elem, attrs) ->
    $timeout ->
      # elem.find(".open-profile-apply-modal").click ->
      #   $('#profile-apply-modal').modal()

profileInternships.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "profileInternships", profileInternships
