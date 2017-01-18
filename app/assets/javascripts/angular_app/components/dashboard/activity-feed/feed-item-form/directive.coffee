feedItemForm = (CONSTS, $timeout, ModalService, MeedpostFactory, ActivityFeedItemFactory) ->

  ctrl = ($scope) ->
    $scope.publishFormData = {}
    $scope.submitPublish = (isValid = true) ->
      return unless isValid
      $scope.button_loading = true
      MeedpostFactory.update($scope.item._id,
        caption: $scope.item.caption,
        tag_ids: $scope.item.tag_objects.map((tag) -> tag._id),
        collection_ids: $scope.item.collections.map((collection) -> collection._id)
      ).success (data) ->
        item = new ActivityFeedItemFactory(data.data)[0]
        $scope.button_loading = false
        $scope.$emit("editedItem", item)
    $scope.closeForm = ->
      $scope.item.isEditing = false if $scope.item.isEditing
      $scope.$emit("endEditingItem", $scope.item)

  ctrl.$inject = [
    "$scope"
  ]

  linkFn = ($scope, elem, attrs) ->
    autogrow = ->
      if this.value != ''
        this.style.height = "1px"
        this.style.height = (25 + this.scrollHeight)+"px"

    $timeout -> elem.find("textarea").each autogrow
    elem.find("textarea").on "blur keyup change paste", autogrow

  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/dashboard/activity-feed/feed-item-form/view.html"
    replace: true
    scope: {
      item: "="
      allTags: "="
      allCollections: "="
      isEditing: "="
    }
    controller: ctrl
    link: linkFn
  }
feedItemForm.$inject = [
  "CONSTS"
  "$timeout"
  "ModalService"
  "MeedpostFactory"
  "ActivityFeedItemFactory"
]

angular.module("meed").directive "feedItemForm", feedItemForm
