CollectionFactory = (
  CONSTS,
  CollectionsFactory,
  StructFactory
  ) ->
  # Properties to expect coming in from the API
  props = {
    _id: String
    add_to_profile: Boolean
    category: String
    contributor_count: Number
    description: String
    follower_count: Number
    handle: String
    is_viewer_following: Boolean
    large_image_url: String
    medium_image_url: String
    photo_id: String
    public_post: Boolean
    small_image_url: String
    submission_count: Number
    title: String
    url: String
    view_count: Number
  }

  init = (o) ->
    if !o.small_image_url
      o.small_image_url = CONSTS.default_feed_image


  instanceMethods = {
    follow: () ->
      return false unless @_id
      CollectionsFactory.followCollection(@_id).success(
        (data, status, headers, config) =>
          @is_viewer_following = true
      )


    unfollow: () ->
      return false unless @_id
      CollectionsFactory.unfollowCollection(@_id).success(
        (data, status, headers, config) =>
          @is_viewer_following = false
      )
  }

  Collection = StructFactory.build(props, init)
  Collection.prototype = instanceMethods

  Collection


CollectionFactory.$inject = [
  "CONSTS"
  "CollectionsFactory"
  "StructFactory"
]

angular.module('meed').factory 'CollectionFactory', CollectionFactory
