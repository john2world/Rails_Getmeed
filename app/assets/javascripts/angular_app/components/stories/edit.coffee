StoriesEditController = ($scope, $routeParams, StoryFactory) ->
  $scope.story = StoryFactory.edit(slug: $routeParams.slug)

StoriesEditController.$inject = [
  "$scope"
  "$routeParams"
  "StoryFactory"
]

angular.module("meed").controller "StoriesEditController", StoriesEditController
