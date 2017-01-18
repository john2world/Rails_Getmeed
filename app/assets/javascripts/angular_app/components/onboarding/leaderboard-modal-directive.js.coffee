leaderboardModal = ($timeout,
                    $routeParams,
                    CONSTS,
                    UTILS,
                    CollectionsFactory,
                    ProfileFactory,
                    CollectionFactory,
                    FacebookFactory,
                    CompanyFactory,
                    RedirectFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/onboarding/leaderboard-modal.html"
  replace: true
  scope: {
    leaderboardUsers: "="
    currentUser: "="
    prizes: "="
    tags:"="
    allCollections:"="
    feedItems:"="
  }
  link: ($scope, elem, attrs) ->
    $scope.loading = true
    $scope.testInvitations = false
    $timeout ->
      if $routeParams.lb
        $scope.regFlow = true
        if $scope.currentUser
          if $scope.currentUser.show_invite
            $scope.testInvitations = true

          if $scope.currentUser.badge == 'influencer'
            $scope.influencerSignUp = true
            $scope.placeholderText = "Example: I am #{$scope.currentUser.first_name}, I have been working at Google for the past 2 months and looking to help students. I am expert at Data Science, so please ask me anything about it!"
            $scope.defaultTagId = 'ask-me-anything'
          else
            $scope.placeholderText = "Example: Did anyone intern at Microsoft?"
            $scope.influencerSignUp = false
            $scope.defaultTagId = 'question'

        CollectionsFactory.getRecommendedCollections().success (data) ->
          $scope.loading = false
          $scope.showNew = false
          if data.recommended_collections
            $scope.recommendedCollections = data.recommended_collections.slice(0, 6).map (e) ->
              new CollectionFactory(e)

            $scope.joinedCollections = data.following_collections.map (e) ->
              new CollectionFactory(e)


            $(".show-influencer-steps").removeAttr('disabled')
        $scope.referral_url = "https://getmeed.com/?referrer=#{$scope.currentUser.handle}"

        if $scope.currentUser.badge != 'influencer'
          ProfileFactory.getUserRecommendations().success (data) ->
            if data.recommended_users
              $scope.recommendedUsers = data.recommended_users.slice(0, 6)
              $(".show-social-steps").removeAttr('disabled')

          ProfileFactory.getLeadUserRecommendations().success (data) ->
            if data.lead_users
              $scope.leadUsers = data.lead_users.slice(0, 6)

      numberOfFollows = 2
      numberOfInfluencerFollows = 2
      $('.facebook-import').click ->
        $scope.loading = true
        $('.facebook-import').hide()
        FacebookFactory.saveFacebookFriends(RedirectFactory.getRedirectUrl())

      $(".show-influencer-steps").click ->
        $scope.loading = false
        if $scope.influencerSignUp
          $(".leaderboard").hide()
          $(".welcome-steps").hide()
          $(".company-steps").hide()
          $(".meed-points").hide()
          $(".influencer-steps").hide()
          if $scope.testInvitations
            $(".invite-steps").show()
            $(".social-steps").hide()
          else
            $(".social-steps").show()
        else
          $(".leaderboard").hide()
          $(".welcome-steps").hide()
          $(".company-steps").hide()
          $(".meed-points").hide()
          $(".influencer-steps").show()

      $(".show-meed-points").click ->
        $(".leaderboard").hide()
        $(".welcome-steps").hide()
        $(".company-steps").hide()
        $(".influencer-steps").hide()
        $(".meed-badges").hide()
        $(".meed-points").show()

      $(".show-meed-badges").click ->
        $(".leaderboard").hide()
        $(".welcome-steps").hide()
        $(".influencer-steps").hide()
        $(".company-steps").hide()
        $(".meed-points").hide()
        $(".meed-badges").show()

      $(".show-leaderboard").click ->
        $(".leaderboard").show()
        $(".meed-points").hide()
        $(".company-steps").hide()
        $(".influencer-steps").hide()
        $(".welcome-steps").hide()

      $(".close-leaderboard-modal").click ->
        $.modal.close()

      $(".show-social-steps").click ->
        $(".leaderboard").hide()
        $(".welcome-steps").hide()
        $(".company-steps").hide()
        $(".meed-points").hide()
        $(".influencer-steps").hide()
        if $scope.testInvitations
          $(".invite-steps").show()
          $(".social-steps").hide()
        else
          $(".social-steps").show()


      $(".show-end-steps").click ->
        $.modal.close()

      $(".show-continue-steps").click ->
        if RedirectFactory.hasRedirect
          RedirectFactory.followRedirectUrl()
        else
          UTILS.redirect('/')


leaderboardModal.$inject = [
  "$timeout"
  "$routeParams"
  "CONSTS"
  "UTILS"
  "CollectionsFactory"
  "ProfileFactory"
  "CollectionFactory"
  "FacebookFactory"
  "CompanyFactory"
  "RedirectFactory"
]

angular.module("meed").directive "leaderboardModal", leaderboardModal
