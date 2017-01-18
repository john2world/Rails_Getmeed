JobsApplicationsIndexController = ($scope, $filter, $routeParams, MeedApiFactory, CONSTS, UTILS) ->
  $scope.getMore = ->
    return if $scope.scroll_fetching
    $scope.scroll_fetching = true
    MeedApiFactory.get(url: "/job_applicants?type=#{$scope.tab}&page=#{$scope.page}", cached: true).success (applicants) ->
      $scope.scroll_fetching = false
      if applicants.length > 0
        for app in applicants
          $scope.applicants.push app
      else
        $scope.scroll_disabled = true
      $scope.page += 1

  $scope.showTab = (tab) ->
    $scope.applicants = []
    $scope.tab = tab
    $scope.page = 1
    $scope.scroll_fetching = false
    $scope.scroll_disabled = false
    $scope.getMore()

  MeedApiFactory.get("/job_applicants/count").success (data) ->
    $scope.counter = {}
    for k,v of data
      $scope.counter[k] = "(#{$filter('number')(v)})"

  # three type of tabs: applications, recommendations and shortlisted
  $scope.showTab 'shortlisted'

  $scope.$on "archivedApplicant", (event, applicant) ->
    UTILS.removeItemFromList(applicant, $scope.applicants, 'id')

JobsApplicationsIndexController.$inject = [
  "$scope"
  "$filter"
  "$routeParams"
  "MeedApiFactory"
  "CONSTS"
  "UTILS"
]

angular.module("meed").controller "JobsApplicationsIndexController", JobsApplicationsIndexController
