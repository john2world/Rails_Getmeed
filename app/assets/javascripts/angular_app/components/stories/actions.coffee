storyActions = ($timeout, $location, CONSTS, VENDOR, MeedApiFactory, StoryFactory, CompanyFactory, $mdDialog) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/stories/actions.html"
  replace: false
  scope:
    story: "="
    currentUser: "="
  link: ($scope, elem, attrs) ->
    $scope.showConfirm = (ev) ->
      confirm = $mdDialog.confirm()
        .title('Are you sure to delete your story?')
        .textContent('All content of your story will be deleted.')
        .targetEvent(ev)
        .ok('Yes')
        .cancel('No')
      $mdDialog.show(confirm).then( ->
        StoryFactory.delete slug: $scope.story.slug
        $location.path '/'
      )

storyActions.$inject = [
  "$timeout"
  "$location"
  "CONSTS"
  "VENDOR"
  "MeedApiFactory"
  "StoryFactory"
  'CompanyFactory'
  '$mdDialog'
]

angular.module("meed").directive "storyActions", storyActions
