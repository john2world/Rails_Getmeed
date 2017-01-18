# A simple factory for retrieving a single job
JobFactory = (MeedApiFactory) ->
  getJob = (slug) ->
    return MeedApiFactory.get("job/#{slug}.json")

  applyJob = (id, data) ->
    url = "/job/apply?id=#{id}"
    MeedApiFactory.post(
      url: url
      data: data
    )

  all = (school_id='', majortype='') ->
    url = "/jobs/all?school=#{school_id}&majortype=#{majortype}"
    MeedApiFactory.get(url)

  getJobsByCategory = (slug, school_id = '', majortype = '', page = 1) ->
    url = "/jobs/#{slug}?school=#{school_id}&majortype=#{majortype}&page=#{page}"
    MeedApiFactory.get(url)

  return {
    getJob: getJob
    applyJob: applyJob
    all: all
    getJobsByCategory: getJobsByCategory
  }

JobFactory.$inject = [
  "MeedApiFactory"
]

angular.module("meed").factory "JobFactory", JobFactory
