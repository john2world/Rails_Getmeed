activityFeedItem = ($timeout, $http, CONSTS, CurrentUserFactory,
  CommentFactory, UTILS) ->

  ctrl = ($scope) ->

    $scope.collectionsDisplay = () ->
      if UTILS.isArray($scope.skills)
        return $scope.skills.join(", ")
      $scope.skills

  ctrl.$inject = [
    "$scope"
  ]

  templateUrl = (type = null, poster_type = "user") ->
    base_dir = "#{CONSTS.components_dir}/dashboard/activity-feed"
    type = templateType(type, poster_type)
    "#{base_dir}/activity-feed-item-#{type}.html"

  templateType = (type = null, poster_type = "user") ->
    return "story" unless type || poster_type == "product"

    if poster_type == "product"
      if type == "recommended_collections"
        ret = "recommended-collections"
      else if type == "recommended_users"
        ret = "recommended-users"
      else if type == "jobs"
        ret = "jobs"
      else if type == "checklist"
        ret = "checklist"
      else
        ret = "product"
    else if type == "story"
      ret = "story"
    else if type == "native_story"
      ret = "native-story"
    else if type == "user_course_review"
      ret = "course-review"
    else if poster_type == "user"
      ret = "user"
    else if poster_type == "company"
      ret = "company"
    ret

  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/dashboard/activity-feed/activity-feed-item.html"
    replace: true
    controller: ctrl
    scope: {
      feedItem: "="
      showUserActions: "@"
      allCollections: "="
      tags: "="
    }
    link: ($scope, elem, attrs) ->
      $scope.templateUrl = templateUrl
      $scope.templateType = templateType
      if CurrentUserFactory.serverSideLoggedIn()
        CurrentUserFactory.getCurrentUser().success (data) ->
          if data.success
            $scope.currentUser = data

      if $scope.feedItem.comments
        $scope.feedItem.comments = $scope.feedItem.comments.map( (e) ->
          new CommentFactory(e)
        )

      $timeout ->
        $scope.$on "editItem", (event, item) -> $scope.isEditing = true
        $scope.$on "endEditingItem", (event, item) -> $scope.isEditing = false
        $scope.$on "editedItem", (event, item) ->
          $scope.isEditing = false
          $scope.feedItem = new ActivityFeedItemFactory(item)

        $scope.$on "deletedComment", (event, comment) ->
          UTILS.removeItemFromList(comment, $scope.feedItem.comments)

        $scope.showNew = true
        elem.find(".ellipsis").ellipsis(true)
        elem.find("abbr.timeago").timeago()
        openFeedSocialModal = () ->
          UTILS.openModal("#feed-item-social-share-" + $scope.feedItem._id, {
            fixed: false, clickClose: true, escapeClose: true,
            showClose: true
          })

        $('#open-share-modal-' + $scope.feedItem._id).on "click", openFeedSocialModal

  }

activityFeedItem.$inject = [
  "$timeout"
  "$http"
  "CONSTS"
  "CurrentUserFactory"
  "CommentFactory"
  "UTILS"
]

angular.module("meed").directive "activityFeedItem", activityFeedItem

