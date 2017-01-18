jobsList = ($timeout, CONSTS, CurrentUserFactory, JobFactory) ->

  ctrl = ($scope) ->
    $scope.page = 2
    $scope.scroll_fetching = false
    $scope.scroll_disabled = false
    $scope.getMoreJobs = () ->
      if $scope.scroll_fetching == true
        return
      $scope.scroll_fetching = true
      JobFactory.getJobsByCategory($scope.$parent.job_category, $scope.$parent.school_id, $scope.$parent.majortype, $scope.page).success (data) ->
        $scope.scroll_fetching = false
        if data.jobs.length > 0
          $scope.$parent.categories = data.categories
          $scope.$parent.jobs = $scope.$parent.jobs.concat data.jobs
          $scope.page += 1
        else
          $scope.scroll_disabled = true

  ctrl.$inject = [
    "$scope"
  ]

  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/jobs/jobs-list.html"
    replace: false
    scope: {
      jobs: "="
      fixedSize: "="
      currentUser: "="
      category: "="
      showNew: "="
    }
    controller: ctrl

    link: ($scope, elem, attrs) ->
      $timeout ->
        if CurrentUserFactory.serverSideLoggedIn()
          CurrentUserFactory.getCurrentUser().success (data) ->
            if data.success
              $scope.currentUser = data
    }

jobsList.$inject = [
  "$timeout"
  "CONSTS"
  "CurrentUserFactory"
  "JobFactory"
]

angular.module("meed").directive "jobsList", jobsList
