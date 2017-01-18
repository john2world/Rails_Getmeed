HeaderNavController = (
  $scope,
  $routeParams,
  $timeout,
  $cookies,
  CONSTS,
  VENDOR,
  UTILS,
  HeaderNavFactory,
  CurrentUserFactory,
  NotificationsFactory,
  CollectionsFactory,
  CollectionFactory,
  ActivityFeedFactory,
  RedirectFactory) ->

  $scope.CONSTS = CONSTS

  VENDOR.loadFacebook(fbCallback)
  VENDOR.loadTwitter(twitterCallback)
  $scope.filepickerApiKey = CONSTS.filepicker_api_key
  $scope.influencer_header = false
  if HeaderNavFactory.isInfluencer()
    $scope.influencer_header = true

  if CurrentUserFactory.serverSideLoggedIn()
    $scope.loggedIn = true
    CurrentUserFactory.getCurrentUser().success (data) ->
      if data.success
        $scope.currentUser = data
        data.notifications_count = 0 if !data.notifications_count
        $scope.notificationsCount = data.notifications_count
        NotificationsFactory.getNotificationsCache(userNotificationsCb)

        $scope.resetNotifications = () ->
          return unless $scope.notificationsCount > 0
          NotificationsFactory.resetNotifications().success (data) ->
            $scope.notificationsCount = 0

  fbCallback = () ->
    FB.Event.subscribe "edge.create", (href, widget) ->
      NotificationsFactory.incrementMeedPoints "facebook", (data) ->
        $scope.currentUser.meed_points = data.meed_points


  twitterCallback = () ->
    twttr.ready ->
      twttr.events.bind "follow", (event) ->
        NotificationsFactory.incrementMeedPoints "twitter", (data) ->
          $scope.currentUser.meed_points = data.meed_points
        # console.log "Followed"
        # followedUserId = event.data.user_id
        # followedScreenName = event.data.screen_name


  userNotificationsCb = (data) ->
    $scope.notifications = data

  userFollowingCollectionCb = (data) ->
    $scope.loading = false
    if data.collections
      $scope.userCollections = data.collections.map (e) ->
        new CollectionFactory(e)

    if data.trending_tags
      $scope.trendingTags = data.trending_tags

  userCollectionsCb = (data) ->
    $scope.loading = false
    $scope.tags = data.tags
    $scope.publicCollections = data.public_collections.map (e) ->
      new CollectionFactory(e)
    $scope.allCollections = $scope.publicCollections

  allFeedItemsCb = (data) ->
    $scope.allFeedItems = data.feed.map( (e) ->
      new ActivityFeedItemFactory(e)
    )
    $scope.allFeedActions = data.actions
    $scope.hasFeedItems = $scope.allFeedItems.length > 0

  CollectionsFactory.getUserFollowingCollectionsCached(userFollowingCollectionCb)
  CollectionsFactory.getUserCollectionsCached(userCollectionsCb)

  $timeout ->
    VENDOR.loadFilepicker(VENDOR.createFilepickerWidgets)
    if $routeParams.lb
      $scope.regFlow = true
    else
      $scope.regFlow = false

    if $routeParams.redirect_url && $routeParams.redirect_url != ''
      RedirectFactory.setRedirectUrl($routeParams.redirect_url)
      # clear it
      $routeParams.redirect_url = null

    # saving referrer in cookiez
    if $routeParams.referrer && $routeParams.referrer != ''
      $cookies.put("referrer", $routeParams.referrer)

    if $routeParams.action && $routeParams.action == 'signin'
      if !CurrentUserFactory.serverSideLoggedIn()
        UTILS.openModal("#signup-form", {clickClose: false, escapeClose: false, showClose: false})



HeaderNavController.$inject = [
  "$scope"
  "$routeParams"
  "$timeout"
  "$cookies"
  "CONSTS"
  "VENDOR"
  "UTILS"
  "HeaderNavFactory"
  "CurrentUserFactory"
  "NotificationsFactory"
  "CollectionsFactory"
  "CollectionFactory"
  "ActivityFeedFactory"
  "RedirectFactory"

]

angular.module("meed").controller "HeaderNavController", HeaderNavController
