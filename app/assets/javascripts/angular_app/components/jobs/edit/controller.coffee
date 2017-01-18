JobsEditController = ($scope, $routeParams, MeedApiFactory) ->
  $scope.job =
    type: ""
    skills: []
    schools: []
    majors: []
    question: {}

  MeedApiFactory.get("/jobs/#{$routeParams.id}/edit").success (data) ->
    $scope.job = data.job

JobsEditController.$inject = [
  "$scope"
  "$routeParams"
  "MeedApiFactory"
]

angular.module("meed").controller "JobsEditController", JobsEditController
