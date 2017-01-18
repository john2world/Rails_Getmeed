CommentFactory = (MeedApiFactory, StructFactory) ->

  # Properties to expect coming in from the API
  props = {
    _id: String
    code_description: String
    commenter_tagline: String
    create_time: String
    description: String
    downvote_count: Number
    feed_id: String
    gist_id: String
    has_viewer_upvoted: Boolean
    is_viewer_author: Boolean
    is_viewer_moderator : Boolean
    lang_type: String
    poster_id: String
    poster_type: String
    upvote_count: Number
    user: Object
    deleted: Boolean
  }

  _upvote = (id) ->
    url  = "/upvotes/#{id}"
    MeedApiFactory.post(url)

  _del = (id) ->
    data = {
      comment_id: id
    }
    url = "/comments/delete"
    MeedApiFactory.post( url: url, data: data)


  instanceMethods = {
    upvote: () ->
      _upvote(@_id).success(
        (data, status, headers, config) =>
          @has_viewer_upvoted = true
          @upvote_count = data.upvote_count
      )

    del: (success = false) ->
      _del(@_id).success(success)
  }

  Comment = StructFactory.build(props)
  Comment.prototype = instanceMethods

  # Static methods go here
  Comment.submitComment = (data) ->
    url = "/comments/create"
    MeedApiFactory.post({url: url, data: data})

  Comment.updateComment = (id, data) ->
    url = "/comments/#{id}/update"
    MeedApiFactory.post({url: url, data: data})

  Comment


CommentFactory.$inject = [
  "MeedApiFactory"
  "StructFactory"
]

angular.module('meed').factory 'CommentFactory', CommentFactory
