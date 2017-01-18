checkList = ($timeout,
             UTILS,
             CONSTS,
             CompanyFactory,
             CurrentUserFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/dashboard/activity-feed/check-list.html"
  replace: false
  scope: {
    item: "="
  }
  link: ($scope, elem, attrs) ->
    if CurrentUserFactory.serverSideLoggedIn()
      CurrentUserFactory.getCurrentUser().success (data) ->
        if data.success
          $scope.currentUser = data
    $timeout ->
      openCollectionFollowModal = () ->
        $("#leaderboard-modal").attr('style', 'width:55%')
        UTILS.openModal("#leaderboard-modal", {
          fixed: false, clickClose: true, escapeClose: true,
          showClose: true, marginTopOffset: 200
        })
        $(".leaderboard").hide()
        $(".welcome-steps").show()
        $(".social-steps").hide()
        $(".company-steps").hide()
        $(".meed-points").hide()
        waitForSomeTime = $timeout((->
          $.modal.resize()
        ), 250)

      openCompanyFollowModal = () ->
        $("#leaderboard-modal").attr('style', 'width:55%')
        UTILS.openModal("#leaderboard-modal", {
          fixed: false, clickClose: true, escapeClose: true,
          showClose: true, marginTopOffset: 200
        })
        $(".leaderboard").hide()
        $(".welcome-steps").hide()
        $(".social-steps").hide()
        $(".company-steps").show()
        $(".meed-points").hide()
        waitForSomeTime = $timeout((->
          $.modal.resize()
        ), 250)

      openBadgeModal = () ->
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


      $(document).on "click", ".open-collection-modal", {}, openCollectionFollowModal
      $(document).on "click", ".open-company-modal", {}, openCompanyFollowModal
      $(document).on "click", ".open-badge-modal", openBadgeModal


checkList.$inject = [
  "$timeout"
  "UTILS"
  "CONSTS"
  "CompanyFactory"
  "CurrentUserFactory"
]

angular.module("meed").directive "checkList", checkList

