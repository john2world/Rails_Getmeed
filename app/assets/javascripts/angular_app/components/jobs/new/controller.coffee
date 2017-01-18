JobsNewController = ($scope) ->
  $scope.job =
    type: ""
    skills: []
    schools: []
    majors: []
    question: {}

JobsNewController.$inject = [
  "$scope"
]

angular.module("meed").controller "JobsNewController", JobsNewController
