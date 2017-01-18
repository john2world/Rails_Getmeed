# Simple service for retrieving job feed for the main dashboard

JobFeedFactory = ($cacheFactory, MeedApiFactory) ->

  jobFeedCache = $cacheFactory("jobFeedCache")

  # This includes "my jobs" in the stream of jobs.
  # "My jobs" are just jobs where job.applied == true
  all = (page = 1, school = '', majortype = '', year = '', cache = jobFeedCache) ->
    url = feedGetUrl(page, school, majortype, year)
    return MeedApiFactory.get(url: url, cache: cache)


  setJobCounts = (scope) ->
    scope.miniInternshipCount = 0
    angular.forEach scope.jobs, (job) ->
      scope.miniInternshipCount += 1 if job.type.toLowerCase().startsWith("mini internship")
    scope.internshipCount = 0
    angular.forEach scope.jobs, (job) ->
      scope.internshipCount += 1 if job.type.toLowerCase().startsWith("intern")
    scope.fulltimeCount = 0
    angular.forEach scope.jobs, (job) ->
      scope.fulltimeCount += 1 if job.type.toLowerCase().startsWith("full")


  feedGetUrl = (page = 1, school = '', majortype = '', year = '') ->
    if school || majortype || year
      "/jobs/load?page=#{page}&school=#{school}&majortype=#{majortype}&year=#{year}"
    else
      "/jobs/load?page=#{page}"

  # Returns the cached data first, then grabs the data in the background
  allCachedThenUncached = (cb, school, majortype, year) ->

    page = 1
    url = feedGetUrl(page, school, majortype, year)
    if jobFeedCache.get(url)
      all(1, school, majortype, year, jobFeedCache).success (data) ->
        cb(data)
        all(1, school, majortype, year, false).success cb
    else
      all(1, school, majortype, year, jobFeedCache).success (data) ->
        cb(data)

  # myJobs = (page = 1) ->
  #   return $http.get("/jobs/load?position=applied&page=#{page}")

  return {
    all: all
    allCachedThenUncached: allCachedThenUncached
    setJobCounts: setJobCounts
  }

JobFeedFactory.$inject = [
  "$cacheFactory"
  "MeedApiFactory"
]

angular.module("meed").factory "JobFeedFactory", JobFeedFactory
