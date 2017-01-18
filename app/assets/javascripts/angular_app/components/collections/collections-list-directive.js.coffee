collectionsList = ($timeout, CONSTS, CurrentUserFactory) ->

  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/collections/collections-list.html"
    replace: true
    scope: {
      collections: "="
      currentUser: "="
      userCollections: "@"
      category: "="
      showNew: "="
    }

    link: ($scope, elem, attrs) ->
      $timeout ->
        if CurrentUserFactory.serverSideLoggedIn()
          CurrentUserFactory.getCurrentUser().success (data) ->
            if data.success
              $scope.currentUser = data

  }

collectionsList.$inject = [
  "$timeout"
  "CONSTS"
  "CurrentUserFactory"
]

angular.module("meed").directive "collectionsList", collectionsList
