storyForm = ($timeout, $location, CONSTS, VENDOR, MeedApiFactory, StoryFactory, CompanyFactory) ->
  ctrl = ($scope) ->
    $scope.filepickerApiKey = CONSTS.filepicker_api_key

  ctrl.$inject = [
    "$scope"
  ]
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/stories/form.html"
  replace: true
  controller: ctrl
  scope:
    story: "="
    tags: "="
    allCollections: "="
  link: ($scope, elem, attrs) ->
    $scope.default_image = CONSTS.default_image
    $scope.submit = (story, valid) ->
      return unless valid
      if story.slug
        StoryFactory.update(slug: story.slug, story: story, (story, headers, c) ->
          console.log headers('Location')
          $location.path("/#{story.user.handle}/stories/#{story.slug}").search()
        )
      else
        StoryFactory.save(story: story, (story, headers, c) ->
          console.log headers('Location')
          $location.path("/#{story.user.handle}/stories/#{story.slug}").search()
        )

storyForm.$inject = [
  "$timeout"
  "$location"
  "CONSTS"
  "VENDOR"
  "MeedApiFactory"
  "StoryFactory"
  'CompanyFactory'
]

angular.module("meed").directive "storyForm", storyForm
