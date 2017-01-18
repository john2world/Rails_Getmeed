ActivityFeedItemFactory = (
  CONSTS,
  ArticleFactory,
  ProfileFactory,
  CollectionFactory,
  CompanyFactory,
  MeedApiFactory,
  StructFactory) ->

  # Properties to expect coming in from the API
  props = {
    _id: String
    add_to_profile: Boolean
    caption: String
    collection_id: String
    collections: Array
    comment_count: Number
    create_time: String
    description: String
    embed_code: String
    external_url: String
    feed_rank: Number
    helper_text: String
    internal_id: String
    is_viewer_following: Boolean
    is_anonymous: Boolean
    job_ids: Array
    kudos_count: Number
    large_image_url: String
    medium_image_url: String
    path: String
    photo_id: String
    poster_id: String
    poster_logo: String
    poster_school: String
    poster_type: String
    privacies: Array
    privacy: String
    privacy_text: String
    public_post: Boolean
    scrape_id: String
    small_image_url: String
    subject_id: String
    tag_line: String
    tags: Array
    title: String
    type: String
    url: String
    user: Object
    video_id: String
    video_type: String
    view_count: Number
  }

  _giveKudos = (id) ->
    url  = "/kudos/#{id}"
    MeedApiFactory.post(url)

  _delete = (id) ->
    data = {
      feed_id: id
    }
    url = "/feed/delete"
    MeedApiFactory.post( url: url, data: data)

  _trackClick = (id) ->
    url = "/feed/track/click/#{id}"
    MeedApiFactory.post(url)

  init = (o) ->
    if o.user && !o.user.image_url
      o.image_url = CONSTS.default_avatar
    if o.company && !o.company.company_logo
      o.company.company_logo = CONSTS.default_image
    if o.type == "story" && !o.small_image_url && o.title
      o.small_image_url = CONSTS.default_feed_image
    if o.type =="recommended_collections"
      o.collections = o.collections.map (e) ->
        new CollectionFactory(e)
    if o.type == "story"
      ArticleFactory.addArticleToCache(o.path, o)

  instanceMethods = {
    follow: () ->
      ProfileFactory.followUser(@poster_id).success(
        (data, status, headers, config) =>
          @is_viewer_following = true
          @isFollowing = true
      )

    delete: (success = false) ->
      _delete(@_id).success(success)

    unfollow: () ->
      return false unless @company && @company._id
      CompanyFactory.unfollow(@company._id).success(
        (data, status, headers, config) =>
          @is_user_following_company = false
      )

    giveKudos: () ->
      _giveKudos(@_id).success(
        (data, status, headers, config) =>
          @viewer_gave_kudos = true
          @kudos_count = data.kudos_count
      )

    downvote: () ->
      MeedApiFactory.put("/feed_items/#{@_id}/downvote").success (feed_item) =>
        @downvoted = true

    trackClick: () ->
      _trackClick(@subject_id)


    # headline: () ->
    #   return false unless @user
    #   return @user.headline if @user.headline
    #   if @user.school
    #     return "Class of #{@user.year}, #{@user.school}"
    #   "Class of #{@user.year}"
  }

  ActivityFeedItem = StructFactory.build(props, init)
  ActivityFeedItem.prototype = instanceMethods


  ActivityFeedItem


ActivityFeedItemFactory.$inject = [
  "CONSTS"
  "ArticleFactory"
  "ProfileFactory"
  "CollectionFactory"
  "CompanyFactory"
  "MeedApiFactory"
  "StructFactory"
]

angular.module('meed').factory 'ActivityFeedItemFactory', ActivityFeedItemFactory
