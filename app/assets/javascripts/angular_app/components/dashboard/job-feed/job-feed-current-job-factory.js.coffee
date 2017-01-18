JobFeedCurrentJobFactory = () ->
  job: null
  setJob: (job) ->
    @job = job
  getJob: () ->
    @job

angular.module("meed").factory "JobFeedCurrentJobFactory", JobFeedCurrentJobFactory
