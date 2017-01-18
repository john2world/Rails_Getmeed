jobCategoriesList = ($timeout, CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/jobs/job-categories-list.html"
  replace: true
  scope: {
    cats: "="
    loadCategory: "="
    currentUser: "="
  }
  link: ($scope, elem, attrs) ->
    $timeout ->
# Do stuff

jobCategoriesList.$inject = [
  "$timeout"
  "CONSTS"
]

angular.module("meed").directive "jobCategoriesList", jobCategoriesList
