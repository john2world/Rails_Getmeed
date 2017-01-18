profileCourseProjectEdit = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile-course-project-edit.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $timeout ->
      # do nothing

profileCourseProjectEdit.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "profileCourseProjectEdit", profileCourseProjectEdit
