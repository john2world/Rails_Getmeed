amaHeader = ($timeout, $location, AmaFactory, UTILS, CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/ama/ama-header.html"
  replace: true
  scope: {
    currentUser: "="
    ama: "="
    loadAma: "="
    amaId: "="
    isFollowing: "="
  }

  link: ($scope, elem, attrs) ->
    $timeout ->
      $scope.followAma = (ama_id) ->
        if !$scope.currentUser
          UTILS.openModal "#signup-modal", {
            overlay:     false
            escapeClose: false
            clickClose:  false
            showSpinner: false
            showClose:   false
          }
          return
        if !ama_id
          return
        AmaFactory.followEvent(ama_id, true).then (response) ->
          if response.data.result
            $scope.isFollowing = true
          else
            $scope.isFollowing = false
      $scope.unfollowAma = (ama_id) ->
        if !$scope.currentUser
          UTILS.openModal "#signup-modal", {
            overlay:     false
            escapeClose: false
            clickClose:  false
            showSpinner: false
            showClose:   false
          }
          return

        if !ama_id
          return
        AmaFactory.followEvent(ama_id, false).then (response) ->
          if response.data.result
            $scope.isFollowing = false
          else
            $scope.isFollowing = true
amaHeader.$inject = [
  "$timeout"
  "$location"
  "AmaFactory"
  "UTILS"
  "CONSTS"
]

angular.module("meed").directive "amaHeader", amaHeader
