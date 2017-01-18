module CommentsManager
  include UsersManager
  include UpvotesManager
  include CommonHelper

  def get_comments_for_feed(viewer, feed_id)
    comments = Comment.where(:feed_id => feed_id.to_s).order_by([:create_time, 1])
    build_comment_models(viewer, comments)
  end

  def get_comments_map_for_feed_ids(viewer, feed_ids)
    comments = Comment.where(:feed_id.in => feed_ids).order_by([:create_time, 1]).to_a
    models = build_comment_models(viewer, comments)
    feed_comment_map = Hash.new { |h, k| h[k] = Array.new }

    models.each do |comment|
      feed_comment_map[comment.feed_id.to_s] << comment
    end
    feed_comment_map
  end

  def get_comments(viewer, comment_ids)
    comments = Comment.where(:_id => comment_ids)
    build_comment_models(viewer, comments)
  end

  def remove_comment_by_id(id)
    comment = Comment.find(id)
    unless comment.blank?
      decrement_comment_count(comment.feed_id)
      comment.delete
    end
  end

  def build_comment_models(viewer=nil, comments)
    if comments.blank?
      return Array.new
    end
    user_handles = Array.new
    comments.each do |comment|
      user_handles << comment.poster_id
    end

    user_map = get_users_map_handles(user_handles)
    comment_models = Array.new
    comments.each do |comment|
      user = user_map[comment.poster_id]
      unless viewer.blank?
        user_upvotes = get_user_upvotes(viewer.handle)
        if !viewer.blank? and !user.blank? and user.handle == viewer.handle
          comment[:is_viewer_author] = true
        else
          comment[:is_viewer_author] = false
        end
        if !user_upvotes.blank? and !user_upvotes[:comment_ids].blank?
          comment[:has_viewer_upvoted] = user_upvotes.comment_ids.include? comment.id.to_s
        end
      end

      if comment[:upvote_count].blank?
        comment[:upvote_count] = 0
      end

      unless user.blank?
        comment[:user] = user
        comment[:user][:name] = user.name
      end
      comment_models << comment
    end
    comment_models
  end

  def get_comment_id(comment_id)
    Comment.find(comment_id)
  end

  def create_comment(handle, params)
    comment = Comment.new
    comment.commenter_tagline = params[:commenter_tagline]
    comment.feed_id = params[:feed_id]
    comment.description = process_text(params[:comment_description][0])
    comment.poster_id = handle
    comment.poster_type = 'user'
    comment.create_time = Time.now
    begin
      comment.save!
    rescue Exception => ex
    end

    increment_comment_count(params[:feed_id], handle)
    if Rails.env.development?
      test_comments_email(comment.id.to_s)
    else
      EmailCommentsWorker.perform_async(comment.id.to_s)
      reward_for_comment_added(comment.poster_id, comment.feed_id)
    end
    comment
  end

  def create_comment_from_feed_caption(feed_item, viewer=nil)
    unless feed_item.caption.blank?
      comment = Comment.new
      comment.description = feed_item.caption
      comment.feed_id = feed_item.id
      comment.poster_id = feed_item.poster_id
      comment.poster_type = feed_item.poster_type
      begin
        comment.save!
      rescue Exception => ex
      end
      increment_comment_count(feed_item.id, feed_item.poster_id)
      if viewer.blank?
        return comment
      else
        return build_comment_models(viewer, Array(comment))[0]
      end

    end
  end

  def test_comments_email(comment_id)
    Rails.cache.delete_matched("#{REDIS_KEYS::CACHE_FEED_ITEM_USER_STORIES}*")
    comment = get_comment_id(comment_id)
    if comment.blank?
      return
    end
    content = get_feed_item_for_id(comment.feed_id)
    if content.blank?
      return
    end
    all_comments = get_comments_for_feed(nil, comment.feed_id)
    audience_handles = Array.new
    all_comments.each do |threaded_comment|
      if !comment.poster_id.eql? threaded_comment.poster_id and !content.poster_id.eql? threaded_comment.poster_id
        audience_handles << threaded_comment.poster_id
      end
    end
    all_user_handles = Array.new
    all_user_handles << comment.poster_id
    all_user_handles.concat audience_handles
    all_user_handles << content.poster_id

    user_map = get_users_map_handles(all_user_handles)

    unless comment.poster_id.eql? content.poster_id
      content_owner = user_map[content.poster_id]
      user_map[comment.poster_id][:rank] = get_leaderboard_rank(user_map[comment.poster_id][:meed_points])
      Notifier.email_comment_content_owner(user_map[comment.poster_id], user_map[content.poster_id], comment, content).deliver
      begin
        create_notification(content.poster_id, comment.poster_id, content.id, MeedNotificationType::COMMENT_STORY)
      rescue Exception => ex
        logger.info('something went wrong saving the notification' + ex.message)
      end
      save_user_state(content_owner.handle, UserStateTypes::COMMENT_RECEIVE_DATE)
    end
    audience_handles.each do |comment_handle|
      Notifier.email_comment_audience(user_map[comment.poster_id], user_map[comment_handle], comment, content).deliver
      begin
        create_notification(comment_handle, comment.poster_id, content.id, MeedNotificationType::THREADED_COMMENT_STORY)
      rescue Exception => ex
        logger.info('something went wrong saving the notification' + ex.message)
      end
    end
  end

end