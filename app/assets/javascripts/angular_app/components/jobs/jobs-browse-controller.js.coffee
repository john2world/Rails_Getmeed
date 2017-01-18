JobsBrowseController = (
  $scope,
  $location,
  $routeParams,
  $timeout,
  CurrentUserFactory,
  JobFactory) ->

  $scope.categoryTitle = "All Types"
  $scope.showNew = true
  if CurrentUserFactory.serverSideLoggedIn()
    CurrentUserFactory.getCurrentUser().success (data) ->
      if data.success
        $scope.currentUser = data

  if $routeParams.school_id
    $scope.school_id = $routeParams.school_id

  if $routeParams.majortype
    $scope.majortype = $routeParams.majortype

  if $routeParams.slug
    $scope.job_category = $routeParams.slug

  $scope.jobs = []

  $scope.loading = false


  $scope.loadCategory = (slug) ->
    $(".job-category-list-entry a").removeClass("active")
    $("#category-#{slug} a").addClass("active")
    $location.path("/jobs/#{slug}", false)
    $scope.loading = true
    $scope.job_category = slug
    JobFactory.getJobsByCategory(slug, $routeParams.school_id, $routeParams.majortype).success (data) ->
      $scope.loading = false
      $scope.category = data.category
      $scope.jobs = data.jobs
      $scope.categoryTitle = $scope.category

  $timeout ->
    if $routeParams.slug
      $scope.loadCategory($routeParams.slug)


JobsBrowseController.$inject = [
  "$scope"
  "$location"
  "$routeParams"
  "$timeout"
  "CurrentUserFactory"
  "JobFactory"
  "JobFactory"
]

angular.module("meed").controller "JobsBrowseController", JobsBrowseController
