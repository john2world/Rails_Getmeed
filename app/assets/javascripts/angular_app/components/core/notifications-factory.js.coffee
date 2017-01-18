NotificationsFactory = (MeedApiFactory, $cacheFactory) ->
  notificationsCache = $cacheFactory("notificationsCache")

  getNotificationsCache = (cb) ->
    url = "/notifications/get"
    if notificationsCache.get(url)
      getNotifications(notificationsCache).success (data) ->
        cb(data)
        getNotifications(false).success cb
    else
      getNotifications(notificationsCache).success (data) ->
        cb(data)

  getNotifications = () ->
    url = "/notifications/get"
    MeedApiFactory.get(url)

  resetNotifications = () ->
    url = "/notifications/reset/count"
    MeedApiFactory.post(url)

  incrementMeedPoints = (meedPointsType, success = false) ->
    url = "/users/increment/meed_points"

    data = {
      meed_points_type: meedPointsType
    }

    MeedApiFactory.post(
      url: url
      data: data
      success: success
    )

  return {
    getNotifications:      getNotifications
    getNotificationsCache: getNotificationsCache
    resetNotifications:    resetNotifications
    incrementMeedPoints:   incrementMeedPoints
  }

NotificationsFactory.$inject = [
  "MeedApiFactory"
  "$cacheFactory"
]

angular.module("meed").factory "NotificationsFactory", NotificationsFactory
