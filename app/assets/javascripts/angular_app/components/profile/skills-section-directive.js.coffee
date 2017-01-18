skillsSection = (CONSTS, UTILS, $timeout) ->

  ctrl = ($scope) ->
    $scope.skillsDisplay = () ->
      if UTILS.isArray($scope.skills)
        # Sometimes the skills is an array, sometimes it's a string
        return $scope.skills.join(", ")
      $scope.skills

  ctrl.$inject = [
    "$scope"
  ]


  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/profile/skills-section.html"
    replace: true
    scope: {
      skills: "="
    }
    controller: ctrl
    link: ($scope, elem, attrs) ->
      # console.log $scope.skills
  }


skillsSection.$inject = [
  "CONSTS"
  "UTILS"
  "$timeout"
]

angular.module("meed").directive "skillsSection", skillsSection

# http://beta.getmeed.com/profiles/header/save
