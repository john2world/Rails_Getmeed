dashboard = (CONSTS, $timeout, $routeParams, $window, $location) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/dashboard/dashboard.html"
  replace: true
  controller: "DashboardController"
  link: ($scope, elem, attrs) ->
    $scope.selectedTab = 1
    $timeout ->
    $scope.openPostAJob = -> $location.path("/jobs/new")

    $scope.openStoryEditor = ->
      # $location.path("/stories/new").search(type: 'intern')
      # full page reload so that navbar will initialize the filepicker
      $window.location.href = '/stories/new?type=intern'

dashboard.$inject = [
  "CONSTS"
  "$timeout"
  "$routeParams"
  "$window"
  "$location"
]

angular.module("meed").directive "dashboard", dashboard
