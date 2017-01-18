headerNav = (CONSTS, UTILS, HeaderNavFactory, $routeParams, $timeout, $cookies) ->
  linkFn = () ->
    userNavHide = () ->
      $("#user-nav-wrap").hide()
      $("#settings-link").removeClass("active")

    notificationsNavHide = () ->
      $("#user-notifications-wrap").hide()
      $("#notifications-link").removeClass("active")

    userNavShow = () ->
      $("#user-nav-wrap").show()
      $("#settings-link").addClass("active")

    notificationsNavShow = () ->
      $("#user-notifications-wrap").show()
      $("#notifications-link").addClass("active")

    $(document).on 'click', (e) ->
      userNavHide()
      notificationsNavHide()

    $timeout ->
      clicks = true
      $("#settings-link").click (e) ->
        notificationsNavHide()
        $("#user-nav-wrap").toggle()
        $("#settings-link").toggleClass("active")
        e.stopImmediatePropagation()

      $("#notifications-link").click (e) ->
        userNavHide()
        $("#user-notifications-wrap").toggle()
        $("#notifications-link").toggleClass("active")
        e.stopImmediatePropagation()


      openLeaderboardModal = () ->
        $("#leaderboard-modal").attr('style', 'width:65%')
        UTILS.openModal("#leaderboard-modal", {
            fixed: false, clickClose: true, escapeClose: true,
            showClose: true, marginTopOffset: 200
          })
        $(".leaderboard").hide()
        $(".welcome-steps").hide()
        $(".social-steps").hide()
        $(".company-steps").hide()
        $(".meed-points").show()
        waitForSomeTime = $timeout((->
          $.modal.resize()
        ), 250)


      openTutorialModal = () ->
        UTILS.openModal("#leaderboard-modal", {
          fixed: false, clickClose: true, escapeClose: true,
          showClose: true, marginTopOffset: 200
        })

      openBadgeModal = () ->
        $("#leaderboard-modal").attr('style', 'width:65%')
        UTILS.openModal("#leaderboard-modal", {
          fixed: false, clickClose: true, escapeClose: true,
          showClose: true, marginTopOffset: 200
        })
        $(".leaderboard").hide()
        $(".welcome-steps").hide()
        $(".social-steps").hide()
        $(".company-steps").hide()
        $(".meed-points").hide()
        $(".meed-badges").show()
        waitForSomeTime = $timeout((->
          $.modal.resize()
        ), 250)


      openLeaderboardModalRegFlow = () ->
        $("#leaderboard-modal").attr('style', 'width:65%')
        UTILS.openModal("#leaderboard-modal", {
          fixed: false, clickClose: false, escapeClose: false,
          showClose: false
        })

      openInfluencerSignupModal = () ->
        $cookies.put('signup-type', 'influencer')
        UTILS.openModal("#influencer-signup-modal", {fixed: false})

      openSignupModal = () ->
        $cookies.put('signup-type', 'regular')
        UTILS.openModal("#signup-modal", {fixed: false})

      openRulesModal = () ->
        UTILS.openModal("#rules-modal", {fixed: false})

      $(document).on "click", ".open-leaderboard-modal", {}, openLeaderboardModal
      $(document).on "click", ".open-signup-modal", {}, openSignupModal
      $(document).on "click", ".open-rules-modal", {}, openRulesModal
      $(document).on "click", ".write-meed-post", {}, openTutorialModal
      $(document).on "click", ".open-influencer-signup-modal", {}, openInfluencerSignupModal
      $(document).on "click", ".open-badge-modal", openBadgeModal

      if $routeParams.lb
        openLeaderboardModalRegFlow()
        if $routeParams.bd
          $(".leaderboard").hide()
          $(".welcome-steps").hide()
          $(".social-steps").hide()
          $(".company-steps").hide()
          $(".meed-points").hide()
          $(".meed-badges").show()
          waitForSomeTime = $timeout((->
            $.modal.resize()
          ), 250)

        if $routeParams.cp
          $(".leaderboard").hide()
          $(".welcome-steps").hide()
          $(".company-steps").hide()
          $(".influencer-steps").show()
          $(".invite-steps").hide()
          $(".meed-points").hide()
          waitForSomeTime = $timeout((->
            $.modal.resize()
          ), 250)

        if $routeParams.sc
          $(".leaderboard").hide()
          $(".welcome-steps").hide()
          $(".social-steps").show()
          $(".company-steps").hide()
          $(".meed-points").hide()
          $(".meed-badges").hide()
          waitForSomeTime = $timeout((->
            $.modal.resize()
          ), 250)




  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/core/header-nav.html"
    replace: true
    controller: "HeaderNavController"
    link: linkFn
  }

headerNav.$inject = [
  "CONSTS"
  "UTILS"
  "HeaderNavFactory"
  "$routeParams"
  "$timeout"
  "$cookies"
]

angular.module("meed").directive "headerNav", headerNav
