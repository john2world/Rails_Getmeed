StoryFactory = ($resource, $http, ActivityFeedItemFactory, CommentFactory) ->
  transformRequest = (data, headers) ->
    delete data.story.tags
    delete data.story.company
    # if data.story.story_answers_attributes
    #   data.story.story_answers_attributes = data.story.story_answers_attributes.filter (answer) -> answer.content
    angular.toJson(data)

  transformResponse = (raw, headers) ->
    story = angular.fromJson(raw)

    story.feed_item = new ActivityFeedItemFactory(story.feed_item)
    if story.feed_item && story.feed_item.comments
      story.feed_item.comments = story.feed_item.comments.map (comment) ->
        new CommentFactory(comment)

    story

  $resource('/stories/:slug.json', {slug: '@slug'},
    new:
      method: 'GET'
      url: '/stories/new.json?type=:type'
      transformResponse: transformResponse
      params:
        type: '@type'

    get:
      method: 'GET'
      transformResponse: transformResponse

    edit:
      method: 'GET'
      url: '/stories/:slug/edit.json'
      params:
        slug: '@slug'

    save:
      method: 'POST'
      transformRequest: transformRequest

    update:
      method: 'PUT'
      transformRequest: transformRequest

    delete:
      method: 'PUT'
      url: '/stories/:slug/delete.json'
  )

StoryFactory.$inject = [
  "$resource"
  "$http"
  "ActivityFeedItemFactory"
  "CommentFactory"
]

angular.module("meed").factory "StoryFactory", StoryFactory
