MajorsFactory = (MeedApiFactory, $cacheFactory) ->
  majorsDegreesCache = $cacheFactory("majorsDegreesCache")

  all = () ->
    MeedApiFactory.get("/majors", {cached: true})

  getMajorsDegreesCache = (cb) ->
    url ="/majors/degrees"
    if majorsDegreesCache.get(url)
      getMajorsDegrees(majorsDegreesCache).success (data) ->
        cb(data)
        getMajorsDegrees(false).success cb
    else
      getMajorsDegrees(majorsDegreesCache).success (data) ->
        cb(data)

  getMajorsDegrees = () ->
    MeedApiFactory.get("/majors/degrees", {cached: true})

  getMajorsTypes = () ->
    MeedApiFactory.get("/majors/types", {cached: true})

  return {
    all: all
    getMajorsDegrees: getMajorsDegrees
    getMajorsTypes: getMajorsTypes
    getMajorsDegreesCache: getMajorsDegreesCache
  }


MajorsFactory.$inject = [
  "MeedApiFactory"
  "$cacheFactory"
]

angular.module("meed").factory "MajorsFactory", MajorsFactory
