ActivityFeedFactory = (MeedApiFactory, $cacheFactory) ->

  activityFeedCache = $cacheFactory("activityFeedCache")

  all = (cache = activityFeedCache) ->
    MeedApiFactory.get( url: "/feed/load", cache: cache )


  getFeedForTag = (tagId, page =1, pageSize) ->
    MeedApiFactory.get( url: "/feed/tag/#{tagId}?page=#{page}&page_size=#{pageSize}", cached: true )


  getFeedForPage = (page = 1, pageSize) ->
    MeedApiFactory.get( url: "/feed/load?page=#{page}&page_size=#{pageSize}", cached: true )

  getUniversityFeedForPage = (page = 1, pageSize) ->
    MeedApiFactory.get( url: "/feed/load?position=university&page=#{page}&page_size=#{pageSize}", cached: true )

  # Returns the cached data first, then grabs the data in the background
  loadActivityFeedCache = (cb) ->
    if activityFeedCache.get("/feed/load")
      all(activityFeedCache).success (data) ->
        cb(data)
        all(false).success cb
    else
      all(activityFeedCache).success (data) ->
        cb(data)

  overlordFeed = (cb, collection_id) ->
    url = "/feed/load?position=student&cid=#{collection_id}"
    if activityFeedCache.get(url)
      student(activityFeedCache, collection_id).success (data) ->
        cb(data)
        student(false).success cb
    else
      student(activityFeedCache, collection_id).success (data) ->
        cb(data)

  company = (cache = activityFeedCache) ->
    MeedApiFactory.get( url: "/feed/load?position=company", cache: cache )

  courseReview = (cache = activityFeedCache) ->
    MeedApiFactory.get( url: "/feed/load?position=course_review", cache: cache )


  return {
    all:                    all
    loadActivityFeedCache:  loadActivityFeedCache
    overlordFeed:           overlordFeed
    company:                company
    getUniversityFeedForPage: getUniversityFeedForPage
    courseReview:           courseReview
    activityFeedCache:      activityFeedCache
    getFeedForPage:         getFeedForPage
    getFeedForTag:          getFeedForTag
  }

ActivityFeedFactory.$inject = [
  "MeedApiFactory"
  "$cacheFactory"
]

angular.module("meed").factory "ActivityFeedFactory", ActivityFeedFactory
