module MigrationsManager
  include CommonHelper
  include SchoolsManager
  include FeedItemsManager
  include CollectionsManager
  include TagsManager
  include ScrapeManager

  def run_image_migration
    feed_items = FeedItems.where(:small_image_url => 'https://res.cloudinary.com/resume/image/upload/c_fit,r_6,w_150/Screen_Shot_2015-09-04_at_12.30.49_AM_najre6.png').to_a
    feed_items.each do|feed|
      feed.small_image_url = 'https://res.cloudinary.com/resume/image/upload/c_fit,r_6,w_50/Screen_Shot_2015-09-04_at_12.30.49_AM_najre6.png'
      feed.medium_image_url = 'https://res.cloudinary.com/resume/image/upload/c_fit,r_6,w_50/Screen_Shot_2015-09-04_at_12.30.49_AM_najre6.png'
      feed.save
    end
  end

  def link_scrape_to_feed(scrape_title, feed_id)
    feed = get_feed_item_for_id(feed_id)
    scrape = get_scrape_by_title(scrape_title)
    unless feed.blank? or scrape.blank?
      feed.title = scrape.title
      feed.description = scrape.description
      feed.external_url = scrape.url
      feed.scrape_id = scrape.id
      feed.small_image_url = scrape.small_image_url
      feed.medium_image_url = scrape.medium_image_url
      feed.large_image_url = scrape.large_image_url
      feed.last_updated = Time.now
      feed.save
    end

  end


  def run_feed_migration
    feed_items = FeedItems.where(:type => 'story').to_a
    feed_items.each do |item|
      item.last_updated = item.create_time
      kudos = Kudos.where(:feed_id => item.id).order_by([:create_dttm, -1]).to_a
      unless kudos.blank?
        item.last_updated = kudos[0].create_dttm
      end
      comments = Comment.where(:feed_id => item.id).order_by([:create_dttm, -1]).to_a
      unless comments.blank?
        if comments[0].create_time > item.last_updated
          item.last_updated = comments[0].create_time
        end
      end

      item.save
    end
  end

  def migrate_notifications
    ConsumerNotification.all.delete
    kudos = Kudos.all.order_by([:create_dttm, -1]).to_a
    kudos.each do |upvote|
      handle = upvote.handle
      giver_handle = upvote.giver_handle
      create_notification(handle, giver_handle, upvote.feed_id, MeedNotificationType::UPVOTE_STORY, upvote.create_dttm)
    end

    comments = Comment.all.order_by([:create_time, -1]).to_a
    feed_ids = []
    comments.each do |comment|
      feed_ids << comment.feed_id
    end
    feed_items = FeedItems.find(feed_ids)
    feed_map = Hash.new
    feed_items.each do |feed_item|
      feed_map[feed_item.id.to_s] = feed_item
    end

    comments.each do |comment|
      feed_item = feed_map[comment.feed_id]
      unless feed_item.blank?
        create_notification(feed_item.poster_id, comment.poster_id, feed_item.id, MeedNotificationType::COMMENT_STORY, comment.create_time)
      end
    end

    user_follows = UserFollowUser.all.to_a
    user_follows.each do |follow|
      create_notification(follow.handle, follow.follower_handle, follow.handle, MeedNotificationType::FOLLOW_USER, follow.create_dttm)
    end

    user_comment_upvotes = UserUpvotes.all.to_a
    user_comment_upvotes.each do |comment_upvote|
      unless comment_upvote.comment_ids.blank?
        comment_upvote.comment_ids.each do |comment_id|
          comment = get_comment_id(comment_id)
          unless comment.blank?
            create_notification(comment.poster_id, comment_upvote.handle, comment.feed_id, MeedNotificationType::UPVOTE_COMMENT)
          end
        end
      end
    end
  end

  def migrate_create_tags
    tag_hash = {'Portfolio' => 'star',  'Today I Learned' => 'lightbulb-o', 'Currently Working On' => 'hourglass-half', 'In My Opinion' => 'gavel', 'Question' => 'question-circle', 'Currently Reading' => 'leanpub'}
    tag_hash.select { |k,v|
      create_tag(k, true, v)
    }
    get_all_tags
  end

  def run_email_settings_migration
    user_settings = UserSettings.all.to_a
    user_settings.each do |setting|
      setting.email_notification_update_subscription('social', true)
      setting.email_notification_update_subscription('job', true)
      setting.email_notification_update_subscription('message', true)
      setting.email_notification_update_subscription('digest', true)
      setting.save
    end
  end

  def run_user_check_save_migration
    influencers = User.where(:badge => 'influencer', :active => true).to_a
    influencers.each do|influencer|
      influencer.meed_points = 25
      save_user_after_checks(influencer)
      comments = Comment.where(:poster_id => influencer.handle).to_a
      kudos = Kudos.where(:giver_handle => influencer.handle).to_a
      kudos.each do |upvote|
        reward_for_upvotes_given(influencer.handle, upvote.feed_id)
      end
      comments.each do |comment|
        reward_for_comment_added(comment.poster_id, comment.feed_id)
      end
    end

    users = User.where(:badge.ne => 'influencer', :active => true).to_a
    users.each do|user|
      user.meed_points = 25
      save_user_after_checks(user)
      comments = Comment.where(:poster_id => user.handle).to_a
      kudos = Kudos.where(:giver_handle => user.handle).to_a
      kudos.each do |upvote|
        reward_for_upvotes_given(user.handle, upvote.feed_id)
      end
      comments.each do |comment|
        reward_for_comment_added(comment.poster_id, comment.feed_id)
      end
      feed_items = FeedItems.where(:type => 'story', :poster_id => user.handle).to_a
      feed_items.each do |feed|
        reward_for_meed_submission(user.handle)
      end
      kudo_receives = Kudos.where(:handle => user.handle).to_a
      kudo_receives.each do |upvote|
        reward_for_upvote_received(user.handle, upvote.feed_id, upvote.giver_handle)
      end
    end
  end

  def run_user_state_migration
    users = User.where(:active => true).to_a
    users.each do |user|
      feed_items = FeedItems.where(:poster_id => user.handle, :type => 'story', :poster_type => 'user').to_a
      unless feed_items.blank?
        save_user_state(user.handle, UserStateTypes::LAST_SUBMISSION_DATE, false)
      end
      has_portfolio = false
      feed_items.each do|feed_item|
        if feed_item.portfolio
          has_portfolio = true
        end
      end

      if has_portfolio
        save_user_state(user.handle, UserStateTypes::PORTFOLIO_SUBMISSION)
      end
    end

    count = 0
    users.each do |user|
      IntercomUpdateUserStateWorker.perform_async(user.handle)
      count +=1
      if count == 400
        count = 0
        sleep(60)
      end
    end
  end


  def migrate_put_user_in_school_groups(handle, school_handle)
    user = get_user_by_handle(handle)
    school = get_school(school_handle)
    if user.blank? or school.blank?
      return
    end

    unless user.school_id.blank?
      user_major_type = user.major_types[0]
      school = get_school(user.school_id)
      unless school.default_collection_ids.blank?
        school.default_collection_ids.each do |cid|
          follow_collection(handle, cid)
        end
      end
      major_type_cid = get_school_major_collection_id(school.handle, user_major_type)
      follow_collection(handle, major_type_cid)
    end

    #public_default_collections
    user.major_types.each do |major_type|
      public_type_cid = get_public_major_collection_id(major_type)
      follow_collection(handle, public_type_cid)
    end
  end

  def migrate_accurate_major_type(major_id, new_major_type)
    major_id='soc_economics'
    new_major_type = 'business'
    major = Major.find(major_id)
    old_major_type = get_major_type_by_major_id(major_id)
    major.major_type_id = new_major_type
    major.save

    users = User.where(:major_id => major_id, :active => true).to_a
    users.each do |user|
      cid = get_public_major_collection_id(new_major_type)
      follow_id = "#{user.handle}_#{cid}"
      follow_collection = UserFollowCollection.find(follow_id)
      if follow_collection.blank?
        follow_collection = UserFollowCollection.new
        follow_collection.id = follow_id
        follow_collection.follower_id = user.handle
        follow_collection.collection_id = cid
        follow_collection.save
      end
      old_cid = get_public_major_collection_id(old_major_type)
      follow_id = "#{user.handle}_#{old_cid}"
      follow_collection = UserFollowCollection.find(follow_id)
      unless follow_collection.blank?
        follow_collection.delete
      end

      feed_items = FeedItems.where(:poster_id => user.handle).order_by([:create_time, -1]).to_a
      feed_items.each do |feed_item|
        feed_item.collection_ids = [cid]
        feed_item.save
      end
    end
  end

  def delete_unused_collections(collection_ids)
    collections = Collection.find(collection_ids).to_a
    collections.each do |coll|
      if DEFAULT_PUBLIC_CIDS.include? coll.id.to_s
        next
      end
      feed_items = FeedItems.where(:collection_ids => coll.id.to_s).to_a
      if !coll.id.to_s.eql? '5653d347e2a07fe23d000005' and !coll.id.to_s.eql? '5651fbfce2a07fcf3c000002'
        tag = create_tag(coll.title)
      end
      feed_items.each do |feed_item|
        poster_id = feed_item.poster_id
        user = get_user_by_handle(poster_id)
        unless user.blank?
          major_type = get_major_type_by_major_id(user.major_id)
          major_type_cid = get_public_major_collection_id(major_type)
          if major_type_cid.blank?
            next
          end
          feed_item.collection_ids = [major_type_cid]
          unless tag.blank?
            feed_item.tag_ids = [tag.id]
          end
          feed_item.last_updated = Time.now
          feed_item.save
        end
      end
      coll.delete
      UserFollowCollection.delete_all(conditions: { :collection_id => coll.id })
    end
  end

  def convert_collections_feed
    collection_hash = {'56311119e2a07fe0d8000005' => '562017e5e2a07fb91d000028', '5609ac33f03517249800001a' => '562017e5e2a07fb91d000028'}
    collection_hash.select { |k,v|
      collection = Collection.find(k)
      feed_items = FeedItems.where(:collection_ids => k).order_by("create_time DESC").to_a
      follower_handles = get_collection_followers(k)
      feed_items.each do |feed_item|
        unless feed_item.collection_ids.include? v
          feed_item.collection_ids = Array.new
          feed_item.collection_ids << v
          feed_item.save
        end
      end
      follower_handles.each do |follower_handle|
        follow_collection(follower_handle, v)
      end
      collection.delete
    }
  end

  def run_migrate_users_major_id(bad_major_id, desired_major_type_id, desired_major_name)
    bad_major = Major.find(bad_major_id)
    unless bad_major.blank?
      bad_major.delete
    end
    new_major = Major.new
    new_major.id = generate_id_from_text(desired_major_name, '_')
    new_major.code = new_major.id
    new_major.major = desired_major_name
    new_major.major_type_id = desired_major_type_id
    new_major.save
    users = User.where(:major_id => bad_major_id)
    major_type = MajorType.find(desired_major_type_id)
    major_type.major_ids << new_major.id
    major_type.save

    users.each do|user|
      user.major_id = new_major.id
      user.save
    end
  end


  def run_seed_collection_migration
    users = User.any_of(:active => false, :waitlist_no.exists => true).to_a
    users.concat User.where(:active => true).to_a
    users.each do |user|
      if user.blank? or user.badge.blank?
        next
      end
      if user.badge.eql? UserBadgeTypes::INFLUENCER
        seed_collections_for_influencer(user)
      else
        seed_collections_for_user(user)
      end
    end
  end

  def create_school_specific_collections(school_id, display_name, school_cover_image)
    default_school = get_school('usc')
    collection_ids = []
    unless default_school.blank?
      unless default_school.default_collection_ids.blank?
        collection_ids.concat default_school.default_collection_ids
      end

      unless default_school.major_collection_ids.blank?
        collection_ids.concat default_school.major_collection_ids
      end
    end
    default_cids = []
    school_major_cids = []
    collections = Collection.find(collection_ids)
    collections.each do |coll|
      collection = Collection.new
      collection.title = coll.title.sub("USC", "#{school_id.length < 5 ? school_id.upcase : school_id.capitalize }")
      collection.major_types = coll.major_types
      collection.public_post = coll.public_post
      collection.description = coll.description.sub("USC", "#{school_id.upcase}")
      collection.handle = coll.handle
      collection.private = coll.private
      collection.school_id = school_id
      collection.category = school_id
      if default_school.default_collection_ids.include? coll.id.to_s
        collection.small_image_url = school_cover_image
        collection.medium_image_url = school_cover_image
        collection.large_image_url = school_cover_image
        collection.save
        default_cids << collection.id
      else
        collection.small_image_url = coll.small_image_url
        collection.medium_image_url = coll.medium_image_url
        collection.large_image_url = coll.large_image_url
        collection.save
        school_major_cids << collection.id.to_s
      end
    end
    run_school_specific_collections(school_id, display_name, default_cids, school_major_cids)
    feed_items = FeedItems.where(:poster_school => school_id, :type => 'story').to_a
    feed_items.each do |item|
      user = get_user_by_handle(item.poster_id)
      major_type_id = get_major_type_by_major_id(user.major_id)
      major_type_cid = get_school_major_collection_id(school_id, major_type_id)
      new_item = item.dup
      new_item.view_count = 0
      arr = []
      arr << major_type_cid.to_s
      new_item.collection_ids = arr
      new_item.save
    end
  end


  def run_school_specific_collections(school_id, display_category_name, default_collection_ids, school_major_collection_ids)
    school = get_school(school_id)
    create_school_collection_category(school_id, display_category_name)
    school.active = true
    school.default_collection_ids = default_collection_ids
    school.major_collection_ids = school_major_collection_ids
    school.save
    FeedItems.delete_all(conditions: { :poster_school => school_id, :type.in => %w(coursework internship education userwork)})
    users = User.where(:active => true, :_id => /#{school_id}/).to_a
    users.each do |user|
      seed_collections_for_user(user)
    end
  end

end