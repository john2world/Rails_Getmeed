CollectionsFactory = (MeedApiFactory, $cacheFactory) ->

  userFollowingCollectionCache = $cacheFactory("userFollowingCollectionCache")
  userCollectionCache = $cacheFactory("userCollectionCache")

  createCollection = (data) ->
    url = "/collections/create"
    MeedApiFactory.post({url: url, data: data})

  # Returns the cached data first, then grabs the data in the background
  getUserFollowingCollectionsCached = (cb) ->
    url = "/user/collections/following"
    if userFollowingCollectionCache.get(url)
      getUserFollowingCollections(userFollowingCollectionCache).success (data) ->
        cb(data)
        getUserFollowingCollections(false).success cb
    else
      getUserFollowingCollections(userFollowingCollectionCache).success (data) ->
        cb(data)

  getUserFollowingCollections = (cache = userFollowingCollectionCache) ->
    url = "/user/collections/following"
    MeedApiFactory.get({url: url, cache: cache})

  followCollection = (collectionId) ->
    url = "/collection/#{collectionId}/follow"
    MeedApiFactory.post(url)

  getCollection = (collectionId) ->
    url = "/collection/#{collectionId}"
    MeedApiFactory.get({url: url, cached: true})

  getCollectionFull = (slugId, collectionId, page, pageSize) ->
    url = "/collection/#{slugId}/#{collectionId}?page=#{page}&page_size=#{pageSize}"
    MeedApiFactory.get({url: url, cached: true})

  getNewCollectionData = () ->
    url = "/collections/new"
    MeedApiFactory.get({url: url, cached: true})

  getPublicCollections = () ->
    url = "/collections/public"
    MeedApiFactory.get(url)

  getRecommendedCollections = () ->
    url = "/user/collection/recommendations"
    MeedApiFactory.get({url: url, cached: true})

  getUserCollectionsCached = (cb) ->
    url = "/user/collections"
    if userCollectionCache.get(url)
      getUserCollections(userCollectionCache).success (data) ->
        cb(data)
        getUserCollections(false).success cb
    else
      getUserCollections(userCollectionCache).success (data) ->
        cb(data)

  getUserCollections = () ->
    MeedApiFactory.get({url: "/user/collections", cached: true})

  unfollowCollection = (collectionId) ->
    url = "/collection/#{collectionId}/unfollow"
    MeedApiFactory.post(url)

  return {
    createCollection:                     createCollection
    getUserFollowingCollectionsCached:    getUserFollowingCollectionsCached
    getUserCollectionsCached:             getUserCollectionsCached
    followCollection:                     followCollection
    getCollection:                        getCollection
    getCollectionFull:                    getCollectionFull
    getNewCollectionData:                 getNewCollectionData
    getPublicCollections:                 getPublicCollections
    getRecommendedCollections:            getRecommendedCollections
    getUserCollections:                   getUserCollections
    unfollowCollection:                   unfollowCollection
    getUserFollowingCollections:          getUserFollowingCollections
  }

CollectionsFactory.$inject = [
  "MeedApiFactory"
  "$cacheFactory"
]

angular.module("meed").factory "CollectionsFactory", CollectionsFactory
