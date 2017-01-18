JobFeedController = (
  $scope,
  $timeout,
  $routeParams,
  UTILS,
  MeedApiFactory,
  JobFeedFactory,
  JobFeedTabFactory,
  JobFeedCurrentJobFactory,
  JobFeedUIFactory) ->

  setJobCounts = () ->
    $scope.miniInternshipCount = 0
    angular.forEach $scope.jobs, (job) ->
      $scope.miniInternshipCount += 1 if job.type.toLowerCase().startsWith("mini internship")
    $scope.internshipCount = 0
    angular.forEach $scope.jobs, (job) ->
      $scope.internshipCount += 1 if job.type.toLowerCase().startsWith("intern")
    $scope.fulltimeCount = 0
    angular.forEach $scope.jobs, (job) ->
      $scope.fulltimeCount += 1 if job.type.toLowerCase().startsWith("full")
      
  $scope.generateCompensationText = (job) ->
    if job.type == 'Mini Internship (Fixed)'

      if job.fixed_compensation > 0
        return "$#{job.fixed_compensation}"
      else
        return "$"
    else if job.type == 'Mini Internship (Hourly)'
      if job.hourly_compensation > 0
        return "$#{job.hourly_compensation}/hr"
      else
        return "$"
    else
      return "$"

  $scope.getTextImagePlaceholder = UTILS.getTextImagePlaceholder

  if !$routeParams.companySlug
    jobsCb = (data) ->
      $scope.jobs = data
      setJobCounts()

    JobFeedFactory.allCachedThenUncached(jobsCb, $scope.school, $scope.majortype, $scope.year)
      # TODO: deal with error

    # TODO: refactor this

    $scope.jobsPage = 1
    $scope.loadMoreEnabled = true
    $scope.loadMorebusy = false

    # Function for loading more job feed on scroll
    $scope.loadMore = () ->
      if $scope.loadMorebusy || !$scope.loadMoreEnabled
        return
      $scope.loadMorebusy = true
      $scope.jobsPage += 1
      JobFeedFactory.all($scope.jobsPage, $scope.school, $scope.majortype, $scope.year).success (data) =>

        if data.length == 0
          # we have reached the end of the pages
          $scope.loadMoreEnabled = false
          $scope.loadMorebusy = false
          $timeout ->
            JobFeedUIFactory.setJobsContainerWidth()
        else
          $scope.jobs = $scope.jobs.concat(data)
          setJobCounts()
          $scope.loadMorebusy = false
  else
    $timeout -> setJobCounts()

  $scope.tab = JobFeedTabFactory
  if $routeParams.tab
    $scope.tab.setTab($routeParams.tab)

  # Returns true if we should show a given job listing
  $scope.showJob = (job) ->
    $scope.tab.isSet("all") && !job.type.toLowerCase().startsWith("mini internship")||
    ($scope.tab.isSet("myjobs") && job.applied) ||
    $scope.tab.isSet(job.type) ||
    ($scope.tab.isSet("fulltime") && job.type.toLowerCase().startsWith("full_time")) ||
    ($scope.tab.isSet("miniinternship") && job.type.toLowerCase().startsWith("mini internship")) ||
    ($scope.tab.isSet("intern") && job.type.toLowerCase().startsWith("internship"))

JobFeedController.$inject = [
  "$scope"
  "$timeout"
  "$routeParams"
  "UTILS"
  "MeedApiFactory"
  "JobFeedFactory"
  "JobFeedTabFactory"
  "JobFeedCurrentJobFactory"
  "JobFeedUIFactory"
]

angular.module("meed").controller "JobFeedController", JobFeedController
