StoriesShowController = (
  $scope,
  $routeParams,
  StoryFactory) ->
  $scope.story = StoryFactory.get(slug: $routeParams.slug)

StoriesShowController.$inject = [
  "$scope"
  "$routeParams"
  "StoryFactory"
]

angular.module("meed").controller "StoriesShowController", StoriesShowController
