module MEED_POINTS_REWARD_TYPE
  JOBSHARE_SIGNUP = 'jobshare_signup'
  JOBSHARE_JOBAPPLY = 'jobshare_jobapply'
  SCHOOL_PAGE_SIGNUP = 'school_page_sign_up'
  FRIEND_REFERRER = 'friend_referrer'
  FACEBOOK_LIKE = 'facebook_like'
  TWITTER_FOLLOW = 'twitter_follow'
  USER_FOLLOWER = 'user_follower'
  COMPLETE_PROFILE = 'complete_profile'
  COMMENT_MADE = 'comment_made_0'
  SUBMIT_POST = 'submit_post_0'
  UPVOTE_RECEIVED = 'upvote_received_0'
  COMMENT_RECEIVED = 'comment_received_0'
  COLLECTION_CREATE = 'collection_create'
  COLLECTION_FOLLOWER = 'collection_follower'
  VIEWS_RECEIVED = 'views_received'
  UPVOTE_GIVEN = 'upvote_given_0'
end
module MEED_BADGES
  NEW_HIRE = 'new-hire'
  MANAGER = 'manager'
  DIRECTOR = 'director'
  EXECUTIVE = 'executive'
  INFLUENCER = 'influencer'
end

module MEED_BADGE_POINTS
  NEW_HIRE = 0
  MANAGER = 500
  DIRECTOR = 1500
  EXECUTIVE = 4500
  INFLUENCER = 10000
end

module MEED_POINTS
  FRIEND_REFERRER = 50
  FACEBOOK_LIKE = 25
  TWITTER_FOLLOW = 25
  COMPLETE_PROFILE = 30
  SUBMIT_POST = 15
  SUBMIT_FIRST_POST = 50
  USER_FOLLOW = 50
  UPVOTE_RECEIVED = 10
  COMMENT_RECEIVED = 20
  COMMENT_MADE = 20
  VIEWS_RECEIVED = 30
  COLLECTION_CREATE = 50
  USER_FOLLOWER = 10
  COLLECTION_FOLLOWER = 5
  UPVOTE_GIVEN = 5
  COLLECTION_SUBMISSION = 10
end

module MeedPointsTransactionManager
  include UsersManager

  WaitlistFriendReferrerCount = 3

  def already_awarded_fan_page_like(handle)
    id = "#{handle}_#{MEED_POINTS_REWARD_TYPE::FACEBOOK_LIKE}"
    transact = MeedPointsTransaction.find(id)
    !transact.blank?
  end

  def already_awarded_twitter_follow(handle)
    id = "#{handle}_#{MEED_POINTS_REWARD_TYPE::TWITTER_FOLLOW}"
    transact = MeedPointsTransaction.find(id)
    !transact.blank?
  end

  def already_submitted_atleast_once(handle)
    id = "#{handle}_#{MEED_POINTS_REWARD_TYPE::SUBMIT_POST}"
    transact = MeedPointsTransaction.find(id)
    !transact.blank?
  end

  def already_created_portfolio(handle)
    id = "#{handle}_portfolio_#{MEED_POINTS_REWARD_TYPE::COLLECTION_CREATE}"
    transact = MeedPointsTransaction.find(id)
    !transact.blank?
  end

  # Transact for signups leading from user job share
  def referral_share_signup(handle, id, type, user)
    transact = MeedPointsTransaction.new
    transact[:handle] = handle
    transact[:type] = MEED_POINTS_REWARD_TYPE::FRIEND_REFERRER
    # 0 points for sign up transaction
    transact[:points] = MEED_POINTS_REWARD_TYPE::FRIEND_REFERRER
    transact[:data] = {:id => id, :type => type, :handle => user.handle}
    transact.save
  end

  def reward_for_school_sign_up(handle, id, type, user)
    transact = MeedPointsTransaction.new
    transact.id = "#{handle}_#{MEED_POINTS_REWARD_TYPE::SCHOOL_PAGE_SIGNUP}_#{id}"
    transact[:handle] = handle
    transact[:type] = MEED_POINTS_REWARD_TYPE::SCHOOL_PAGE_SIGNUP
    transact[:points] = 0
    transact[:data] = {:id => id, :type => type, :handle => user.id}
    transact.save
  end

  def reward_for_job_application(handle, job, user)
    transact = MeedPointsTransaction.new
    transact.id = "#{handle}_#{MEED_POINTS_REWARD_TYPE::JOBSHARE_JOBAPPLY}_#{job.id}"
    transact[:handle] = handle
    transact[:type] = MEED_POINTS_REWARD_TYPE::JOBSHARE_JOBAPPLY
    transact[:points] = job[:meed_share]
    transact[:data] = {:id => job[:_id], :type => 'job', :handle => user.handle}
    transact.save
    increment_meed_points_for_user(handle, transact[:points])
  end

  def recompute_meed_points_for_user(handle)
    transactions = MeedPointsTransaction.where(:handle => handle).to_a
    meed_points = 25
    transactions.each do |transaction|
      meed_points += transaction.points
    end
    meed_points
  end

  def reward_for_user_follower(handle, follower_handle)
    id = "#{handle}_#{MEED_POINTS_REWARD_TYPE::USER_FOLLOWER}_#{follower_handle}"
    transact = MeedPointsTransaction.find(id)
    if transact.blank?
      transact = MeedPointsTransaction.new
      transact.id = id
      transact[:handle] = handle
      transact[:type] = MEED_POINTS_REWARD_TYPE::USER_FOLLOWER
      transact[:points] = MEED_POINTS::USER_FOLLOWER
      transact[:data] = {:collection_id => follower_handle}
      transact.save
      increment_meed_points_for_user(handle, transact[:points])
    end
  end

  def reward_for_collection_follower(handle, follower_handle, collection_id)
    id = "#{collection_id}_#{MEED_POINTS_REWARD_TYPE::COLLECTION_FOLLOWER}_#{follower_handle}"
    transact = MeedPointsTransaction.find(id)
    if transact.blank?
      transact = MeedPointsTransaction.new
      transact.id = id
      transact[:handle] = handle
      transact[:type] = MEED_POINTS_REWARD_TYPE::COLLECTION_FOLLOWER
      transact[:points] = MEED_POINTS::COLLECTION_FOLLOWER
      transact[:data] = {:collection_id => follower_handle}
      transact.save
      increment_meed_points_for_user(handle, transact[:points])
    end
  end

  def reward_for_collection_create(handle, collection_id)
    id = "#{handle}_#{MEED_POINTS_REWARD_TYPE::COLLECTION_CREATE}"
    transact = MeedPointsTransaction.find(id)
    if transact.blank?
      transact = MeedPointsTransaction.new
      transact.id = id
      transact[:handle] = handle
      transact[:type] = MEED_POINTS_REWARD_TYPE::COLLECTION_CREATE
      transact[:points] = MEED_POINTS::COLLECTION_CREATE
      transact[:data] = {:collection_id => collection_id}
      transact.save
      increment_meed_points_for_user(handle, transact[:points])
    end
  end

  def reward_for_portfolio_create(handle)
    id = "#{handle}_portfolio_#{MEED_POINTS_REWARD_TYPE::COLLECTION_CREATE}"
    transact = MeedPointsTransaction.find(id)
    if transact.blank?
      transact = MeedPointsTransaction.new
      transact.id = id
      transact[:handle] = handle
      transact[:type] = MEED_POINTS_REWARD_TYPE::COLLECTION_CREATE
      transact[:points] = MEED_POINTS::COLLECTION_CREATE
      transact[:data] = {:collection_id => "#{handle}_portfolio"}
      transact.save
      increment_meed_points_for_user(handle, transact[:points])
    end
  end

  def reward_for_friend_referral(handle, friend_handle)
    transact = MeedPointsTransaction.new
    transact.id = "#{handle}_#{MEED_POINTS_REWARD_TYPE::FRIEND_REFERRER}_#{friend_handle}"
    transact[:handle] = handle
    transact[:type] = MEED_POINTS_REWARD_TYPE::FRIEND_REFERRER
    transact[:points] = MEED_POINTS::FRIEND_REFERRER
    transact[:data] = {:handle => friend_handle}
    transact.save
    increment_meed_points_for_user(handle, transact[:points])
    # also send email in case of waitlist
    FriendReferredWorker.perform_async(handle, friend_handle)
  end

  def reward_for_upvote_received(handle, content_id, giver_handle)
    if handle.eql? giver_handle
      return
    end

    id = "#{content_id}_#{MEED_POINTS_REWARD_TYPE::UPVOTE_RECEIVED}_#{giver_handle}"
    transact = MeedPointsTransaction.find(id)
    if transact.blank?
      transact = MeedPointsTransaction.new
      transact.id = id
      transact[:handle] = handle
      transact[:type] = MEED_POINTS_REWARD_TYPE::UPVOTE_RECEIVED
      transact[:points] = MEED_POINTS::UPVOTE_RECEIVED
      transact.save
      increment_meed_points_for_user(handle, transact[:points])
    end

  end

  def reward_for_upvotes_given(handle, content_id)
    id = "#{content_id}_#{MEED_POINTS_REWARD_TYPE::UPVOTE_GIVEN}_#{handle}"
    transact = MeedPointsTransaction.find(id)
    if transact.blank?
      transact = MeedPointsTransaction.new
      transact.id = id
      transact[:handle] = handle
      transact[:type] = MEED_POINTS_REWARD_TYPE::UPVOTE_GIVEN
      transact[:points] = MEED_POINTS::UPVOTE_GIVEN
      transact.save
      increment_meed_points_for_user(handle, transact[:points], MEED_POINTS_REWARD_TYPE::UPVOTE_GIVEN)
    end
  end

  def reward_for_comment_added(handle, content_id)
    id = "#{content_id}_#{MEED_POINTS_REWARD_TYPE::COMMENT_MADE}_#{handle}"
    transact = MeedPointsTransaction.find(id)
    if transact.blank?
      transact = MeedPointsTransaction.new
      transact.id = id
      transact[:handle] = handle
      transact[:type] = MEED_POINTS_REWARD_TYPE::COMMENT_MADE
      transact[:points] = MEED_POINTS::COMMENT_MADE
      transact.save
      increment_meed_points_for_user(handle, transact[:points], MEED_POINTS_REWARD_TYPE::COMMENT_MADE)
    end
  end

  def reward_for_comment_received(handle, content_id, giver_handle)
    if handle.eql? giver_handle
      return
    end
    id = "#{content_id}_#{MEED_POINTS_REWARD_TYPE::COMMENT_RECEIVED}_#{giver_handle}"
    transact = MeedPointsTransaction.find(id)
    if transact.blank?
      transact = MeedPointsTransaction.new
      transact.id = id
      transact[:handle] = handle
      transact[:type] = MEED_POINTS_REWARD_TYPE::COMMENT_RECEIVED
      transact[:points] = MEED_POINTS::COMMENT_RECEIVED
      transact.save
      increment_meed_points_for_user(handle, transact[:points], MEED_POINTS_REWARD_TYPE::COMMENT_RECEIVED)
    end
  end

  def reward_for_views_received(handle, content_id)
    id = "#{handle}_#{MEED_POINTS_REWARD_TYPE::VIEWS_RECEIVED}_#{content_id}"
    transact = MeedPointsTransaction.find(id)
    if transact.blank?
      transact = MeedPointsTransaction.new
      transact.id = "#{handle}_#{MEED_POINTS_REWARD_TYPE::VIEWS_RECEIVED}_#{content_id}"
      transact[:handle] = handle
      transact[:type] = MEED_POINTS_REWARD_TYPE::VIEWS_RECEIVED
      transact[:points] = MEED_POINTS::VIEWS_RECEIVED
      transact.save
      increment_meed_points_for_user(handle, transact[:points], MEED_POINTS_REWARD_TYPE::VIEWS_RECEIVED)
    end
  end

  def reward_for_fan_page_like(handle)
    id = "#{handle}_#{MEED_POINTS_REWARD_TYPE::FACEBOOK_LIKE}"
    transact = MeedPointsTransaction.find(id)
    if transact.blank?
      transact = MeedPointsTransaction.new
      transact.id = id
      transact[:handle] = handle
      transact[:type] = MEED_POINTS_REWARD_TYPE::FACEBOOK_LIKE
      transact[:points] = MEED_POINTS::FACEBOOK_LIKE
      transact.save
      increment_meed_points_for_user(handle, transact[:points], MEED_POINTS_REWARD_TYPE::FACEBOOK_LIKE)
      EmailMeedPointsThanksWorker.perform_async(handle, MEED_POINTS_REWARD_TYPE::FACEBOOK_LIKE)
      return true
    end
    false
  end

  def reward_for_profile_completeness(handle)
    id = "#{handle}_#{MEED_POINTS_REWARD_TYPE::COMPLETE_PROFILE}"
    transact = MeedPointsTransaction.find(id)
    if transact.blank?
      transact = MeedPointsTransaction.new
      transact.id = id
      transact[:handle] = handle
      transact[:type] = MEED_POINTS_REWARD_TYPE::COMPLETE_PROFILE
      transact[:points] = MEED_POINTS::COMPLETE_PROFILE
      transact.save
      increment_meed_points_for_user(handle, transact[:points], MEED_POINTS_REWARD_TYPE::COMPLETE_PROFILE)
      EmailMeedPointsThanksWorker.perform_async(handle, MEED_POINTS_REWARD_TYPE::COMPLETE_PROFILE)
      return true
    end
    false
  end

  def reward_for_meed_submission(handle)
    id = "#{handle}_#{MEED_POINTS_REWARD_TYPE::SUBMIT_POST}"
    first_transact = MeedPointsTransaction.find(id)
    transact = MeedPointsTransaction.new
    transact[:handle] = handle
    transact[:type] = MEED_POINTS_REWARD_TYPE::SUBMIT_POST
    # 0 points for sign up transaction
    transact[:points] = first_transact.blank? ? MEED_POINTS::SUBMIT_FIRST_POST : MEED_POINTS::SUBMIT_POST
    transact.save
    increment_meed_points_for_user(handle, transact[:points], MEED_POINTS_REWARD_TYPE::SUBMIT_POST)
  end

  def reward_for_twitter_follow(handle)
    id = "#{handle}_#{MEED_POINTS_REWARD_TYPE::TWITTER_FOLLOW}"
    transact = MeedPointsTransaction.find(id)
    if transact.blank?
      transact = MeedPointsTransaction.new
      transact.id = id
      transact[:handle] = handle
      transact[:type] = MEED_POINTS_REWARD_TYPE::TWITTER_FOLLOW
      transact[:points] = MEED_POINTS::TWITTER_FOLLOW
      transact.save
      increment_meed_points_for_user(handle, transact[:points], MEED_POINTS_REWARD_TYPE::TWITTER_FOLLOW)
      EmailMeedPointsThanksWorker.perform_async(handle, MEED_POINTS_REWARD_TYPE::TWITTER_FOLLOW)
      return true
    end
    false
  end

  def test_meed_points_worker(handle, type)
    user = get_user_by_handle(handle)
    if user.blank?
      logger.info("user not found. Not sending email for #{handle}")
      return
    end
    user[:rank] = get_leaderboard_rank(user[:meed_points])
    Notifier.email_meed_points_thanks(user, type).deliver
  end

  def get_friend_referral_count(handle)
    return MeedPointsTransaction.where(type: MEED_POINTS_REWARD_TYPE::FRIEND_REFERRER, handle: handle).count()
  end

  def get_friends_referred(handle)
    return MeedPointsTransaction.where(type: MEED_POINTS_REWARD_TYPE::FRIEND_REFERRER, handle: handle).map{|t| t.data["handle"]}
  end
end