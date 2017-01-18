StoriesNewController = ($scope, CONSTS, StoryFactory) ->
  $scope.story = StoryFactory.new(type: 'intern')
  $scope.filepickerApiKey = CONSTS.filepicker_api_key
  $scope.default_image = CONSTS.default_image

StoriesNewController.$inject = [
  "$scope"
  "CONSTS"
  "StoryFactory"
]

angular.module("meed").controller "StoriesNewController", StoriesNewController
