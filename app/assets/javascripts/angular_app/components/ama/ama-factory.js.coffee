AmaFactory = (MeedApiFactory) ->
  eventCache = { }

  addEventToCache = (event_id, data) ->
    eventCache[event_id] = data

  getCachedEvent = (event_id) ->
    eventCache[event_id]

  getEvent = (event_id) ->
    url = "/ama/#{event_id}"
    MeedApiFactory.get({url: url, cached: true})

  followEvent = (event_id, value=true) ->
    url = "/ama/follow/#{event_id}?value=#{value}"
    MeedApiFactory.get({url: url, cached: true})

  return {
    addEventToCache: addEventToCache
    getCachedEvent: getCachedEvent
    getEvent: getEvent
    followEvent: followEvent
  }

AmaFactory.$inject = [
  "MeedApiFactory"
]

angular.module("meed").factory "AmaFactory", AmaFactory
