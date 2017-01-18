TrackedLinkFactory = (MeedApiFactory) ->
  trackClick = (id) ->
    url = "/feed/track/click"
    MeedApiFactory.post url: url, {id: id}
  return {
    trackClick: trackClick
  }

TrackedLinkFactory.$inject = [
  "MeedApiFactory"
]

angular.module("meed").factory "TrackedLinkFactory", TrackedLinkFactory
