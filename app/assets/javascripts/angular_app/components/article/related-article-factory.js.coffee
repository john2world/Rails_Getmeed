RelatedArticleFactory = (CONSTS, StructFactory) ->

  # Properties to expect coming in from the API
  props = {
    path: String
    large_image_url: String
    title: String
  }

  init = (o) ->
    o.large_image_url ||= CONSTS.default_image

  RelatedArticle = StructFactory.build(props, init)
  RelatedArticle


RelatedArticleFactory.$inject = [
  "CONSTS"
  "StructFactory"
]

angular.module('meed').factory 'RelatedArticleFactory', RelatedArticleFactory
