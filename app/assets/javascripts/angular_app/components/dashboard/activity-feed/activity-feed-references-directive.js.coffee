activityFeedReferences = (CONSTS, $timeout, MeedApiFactory) ->

  linkFn = ($scope, elem, attrs) ->
    $scope.submitAction = (action, isValid) ->
      reviews_url = "/feed/action/submit"
      $scope.referencePublishData["action_id"] = action._id
      actions = $scope.actions
      success = (data) ->
        if data.success
          index = actions.indexOf(action)
          actions.splice(index, 1)
      MeedApiFactory.post( url: reviews_url, data: $scope.referencePublishData, success: success )

    $scope.skipAction = (action) ->
      skip_action_url = "/feed/action/skip/#{action._id}"
      MeedApiFactory.get(skip_action_url).success (data) ->
        #remove the action from the list of actions
        actions = $scope.actions
        if data.success
          index = actions.indexOf(action)
          actions.splice(index, 1)

    $scope.referencePublishData = {
    }

  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/dashboard/activity-feed/activity-feed-references.html"
    replace: true
    link: linkFn
    scope: {
      actions: "="
      user: "="
    }
  }

activityFeedReferences.$inject = [
  "CONSTS"
  "$timeout"
  "MeedApiFactory"
]

angular.module("meed").directive "activityFeedReferences", activityFeedReferences
