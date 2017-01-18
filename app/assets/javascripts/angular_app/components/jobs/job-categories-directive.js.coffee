jobCategories = ($timeout, CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/jobs/job-categories.html"
  replace: true

  link: ($scope, elem, attrs) ->
    $timeout ->
# Do stuff

jobCategories.$inject = [
  "$timeout"
  "CONSTS"
]

angular.module("meed").directive "jobCategories", jobCategories
