profileCourseProjects = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-course-projects.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->
      # elem.find(".open-profile-apply-modal").click ->
      #   $('#profile-apply-modal').modal()

profileCourseProjects.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "profileCourseProjects", profileCourseProjects
