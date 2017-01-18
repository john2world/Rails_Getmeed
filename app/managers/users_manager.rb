module UsersManager
  include CommonHelper
  include CompanyManager
  include PhotoManager
  include CrmManager
  include NotificationsManager
  DIRTY_PICTURE = 'user_male4'


  def get_unsubscribed_emails
    EmailUnsubscribe.pluck(:email).compact.uniq
  end

  def get_recommended_school_users(handle)
    user_id_cache = Rails.cache.fetch("#{REDIS_KEYS::CACHE_USER_RECOMMENDATION_IDS }-#{handle}", expires_in: 5.hours) do
      user = get_user_by_handle(handle)
      user_ids = []
      unless user.blank?
        handles = get_user_followee_ids(handle)
        handles << handle
        school_id = user.school_id
        if school_id.blank?
          school_id = get_school_handle_from_email(user.id)
        end
        school_email_regex = Regexp.new('.*' + school_id + "\\.edu")
        user_ids = User.where(:handle.nin => handles, active: true, :major_id => user.major_id).pluck(:handle).to_a
        if user_ids.length < 15
          user_ids = User.where(email: school_email_regex, :handle.nin => handles, active: true).pluck(:handle).to_a
        end
      end
      user_ids
    end
    get_users_by_handles(user_id_cache)
  end


  def get_recommended_influencers_for_user(handle, include_followees=false)
    user = get_user_by_handle(handle)
    user_ids = []
    ret = Rails.cache.fetch("#{REDIS_KEYS::CACHE_INFLUENCER_RECOMMENDATION_IDS}-#{handle}", expires_in: 12.hours) do
      unless handle.blank? and user.blank?
        following_handles = []
        unless include_followees
          following_handles = get_user_followee_ids(handle)
        end
        following_handles << handle
        cids = get_collections_for_user(handle).map(&:id)
        handles = UserFollowCollection.where(:collection_id.in => cids).pluck(:follower_id).to_a
        user_ids = User.where(:badge => 'influencer', :handle.in => handles, :handle.nin => following_handles, :active => true).order_by([:meed_points, -1]).limit(6).pluck(:handle)
      end
      user_ids
    end
    get_users_by_handles(ret)
  end

  def convert_influencer_user(handle)
    user = User.where(:handle => handle).first
    user.badge = 'new-hire'
    unless user.major_types.blank?
      major_type = get_major_type_by_id(user.major_types[0])
      user.major_id = major_type.major_ids[0]
    end
    profile = Profile.where(:handle => handle).first
    profile.objective = user.bio
    user.save
    profile.save
  end

  def get_featured_influencers_for_user(handle)
    unless handle.blank?
      handles = get_user_followee_ids(handle)
      handles << handle
      return User.where(:badge => 'influencer', :handle.nin => handles, :active => true).order_by([:meed_points, -1]).limit(6).to_a
    end
    User.where(:badge => 'influencer', :active => true).order_by([:meed_points, -1]).limit(6).to_a
  end

  def create_follow_user(handle, follower_handle)
    follow_id = "#{handle}_#{follower_handle}"
    user = get_user_by_handle(handle)
    follow_user = UserFollowUser.find(follow_id)
    if follow_user.blank?
      follow_user = UserFollowUser.new
      follow_user.id = follow_id
      follow_user.follower_handle = follower_handle
      follow_user.handle = handle
      follow_user.save
      user.inc(:follower_count, 1)
      begin
        user.save
      rescue Exception => ex
      end
    end
    if Rails.env.development?
      Notifier.email_user_follow(user, get_user_by_handle(follower_handle)).deliver
    else
      EmailUserFollowerWorker.perform_async(follow_id)
    end
  end

  def get_user_follower_ids(handle)
    ret = Rails.cache.fetch("#{REDIS_KEYS::CACHE_USER_FOLLOWER_IDS}-#{handle}", expires_in: 12.hours) do
      UserFollowUser.where(:handle => handle).pluck(:follower_handle).to_a
    end
    ret
  end

  def get_user_followee_ids(handle)
    ret = Rails.cache.fetch("#{REDIS_KEYS::CACHE_USER_FOLLOWEE_IDS}-#{handle}", expires_in: 12.hours) do
      UserFollowUser.where(:follower_handle => handle).pluck(:handle).to_a
    end
    ret
  end

  def delete_follow_user(handle, follower_handle)
    follow_id = "#{handle}_#{follower_handle}"
    user = get_user_by_handle(handle)
    follow_user = UserFollowUser.find(follow_id)
    if follow_user.blank?
      return
    else
      follow_user.delete
      user.inc(:follower_count, -1)
      begin
        user.save
      rescue Exception => ex
      end
    end
  end

  def is_viewer_following(handle, follower_handle)
    if handle.eql? follower_handle
      return true
    end
    follow_id = "#{handle}_#{follower_handle}"
    follow_user = UserFollowUser.find(follow_id)
    !follow_user.blank?
  end

  def save_user_after_checks(user)
    if user.blank?
      return
    end

    if user.headline.blank? or user.headline.eql? "Class of  @#{get_school_handle_from_email(user.id).upcase}" or user.headline.eql? "Class of @#{get_school_handle_from_email(user.id).upcase}" or user.headline.eql? "Class of @"
      user.headline = "Class of #{user.year} @#{get_school_handle_from_email(user.id).upcase}"
    end

    if user.small_image_url.include? DIRTY_PICTURE
      unless user.first_name.blank? and user.last_name.blank?
        text = user.first_name[0] + user.last_name[0]
        user.image_url = get_place_holder_image_url(text, TINY_WIDTH, TINY_WIDTH)
        user.small_image_url = get_place_holder_image_url(text, SMALL_WIDTH, SMALL_WIDTH)
        user.large_image_url = get_place_holder_image_url(text, MEDIUM_WIDTH, MEDIUM_WIDTH)
        #happens sometimess
        unless user.handle.blank?
          save_user_state(user.handle, UserStateTypes::PROFILE_PICTURE_BLANK, true, 'true')
        end
      end
    else
      #happens sometimess
      unless user.handle.blank?
        save_user_state(user.handle, UserStateTypes::PROFILE_PICTURE_BLANK, true, 'false')
      end
    end

    if user.small_image_url.include? "http:"
      user.small_image_url = user.small_image_url.sub("http:", "https:")
      user.image_url = user.image_url.sub(/http:/, "https:")
      user.large_image_url = user.large_image_url.sub(/http:/, "https:")
    end

  end

  def save_user_profile_picture(user_photo, user_handle)
    if user_photo.blank? or user_handle.blank?
      return
    end
    user = get_user_by_handle(user_handle)
    user.image_url = user_photo
    image_url = get_cloudinary_large_image_url(user.handle, user_photo)
    user.large_image_url = image_url.blank? ? user_photo : image_url
    user.small_image_url = get_cloudinary_facial_image_url(user.handle, image_url.blank? ? user_photo : image_url)
    user.save
    user
  end

  def get_leaderboard_users(limit)
    users = User.where(:active => true, :handle.nin => MEED_HANDLES).order_by(:meed_points => 'desc').limit(20).to_a
    compute = $redis.get('recompute_leaderboard_users')
    if compute.blank?
      users.each do |user|
        save_user_after_checks(user)
        user.meed_points = recompute_meed_points_for_user(user.handle)

      end
      users.sort_by(&:meed_points).reverse!
    end
    $redis.set('recompute_leaderboard_users', true)
    $redis.expire('recompute_leaderboard_users', 60*60)
    users.take(limit)
  end

  def get_leaderboard_rank(points)
    count = User.where(:meed_points.gt => points).count
    count + 1
  end

  def increment_meed_points_for_user(handle, points, source = nil)
    user = User.where(:handle => handle).first
    if user.blank?
      return
    end

    unless user.badge.eql? MEED_BADGES::INFLUENCER
      if user.meed_points > MEED_BADGE_POINTS::MANAGER
        user.badge = MEED_BADGES::MANAGER
      end
      if user.meed_points > MEED_BADGE_POINTS::DIRECTOR
        user.badge = MEED_BADGES::DIRECTOR
      end

      if user.meed_points > MEED_BADGE_POINTS::EXECUTIVE
        user.badge = MEED_BADGES::EXECUTIVE
      end
    end

    user.meed_points += points
    begin
      user.save!
    rescue Exception => ex
    end
    save_user_state(handle, UserStateTypes::MEED_BADGE, true, user.badge)
  end

  def get_user_meed_points(user_handle)
    user = User.find_by(handle: user_handle)
    if user.blank?
      return 0
    end
    user.meed_points
  end

  def get_uninterested_emails
    email_unsub_emails = Array.[]
    email_unsub_emails << 'yeaz@stanford.edu'
    email_unsub_emails << 'iacob@usc.edu'
    email_unsub_emails << 'baatarsu@usc.edu'
    email_unsub_emails << 'manjanac@ucla.edu'
    email_unsub_emails << 'zmaleh@usc.edu'
    email_unsub_emails << 'paulinph@usc.edu'
    email_unsub_emails << 'van233@nyu.edu'
    email_unsub_emails << 'belwalka@usc.edu'
    email_unsub_emails << 'uneumann@usc.edu'
    email_unsub_emails << 'boustani@usc.edu'
    email_unsub_emails << 'ketterer@stanford.edu'
    email_unsub_emails << 'anirudh.naulay@nyu.edu'
    email_unsub_emails << 'an1446@nyu.edu'
    email_unsub_emails << 'leng183@ucla.edu'
    email_unsub_emails
  end

  def update_profile_picture(user, photo)
    if photo.blank? or user.blank?
      return
    end
    user.image_url = photo.large_image_url
    begin
      user.save
    rescue Exception => ex
    end
  end

  def get_user_by_handle(handle)
    if handle.blank?
      return nil
    end

    User.find_by(handle: handle.downcase)
  end

  def get_active_user_by_handle(handle)
    if handle.blank?
      return nil
    end
    user = User.where(:handle => handle).first
    build_user_models([user])[0]
  end

  def create_passive_user(email, referrer = nil)
    user = User.new(:email => email)
    user[:active] = false;
    user[:create_dttm] = Time.zone.now
    begin
      user.save
    rescue Exception => ex
      $log.error "Error in saving user!: #{ex}"
      User.remove(user[:email])
      return nil
    end
    # create intercom contact for the passive user
    create_intercom_contact(user, referrer)
    user
  end

  def create_passive_users(emails, referrer = nil)
    emails.each do |email|
      user = User.new(:email => email)
      user[:active] = false;
      user[:create_dttm] = Time.zone.now
      begin
        user.save
      rescue Exception => ex
        $log.error "Error in saving user!: #{ex}"
        User.remove(user[:email])
        return nil
      end
      # create intercom contact for the passive user
      create_intercom_contact(user, referrer)
    end
  end

  def get_user_by_email(email)
    User.find(email)
  end

  def activate_user_live(handle)
    user = User.where(:handle => handle).first
    unless user.blank?
      user.active = true
      user.save
      user
    end
  end

  def activate_wait_list_user(user)
    # create a invitation for the user
    invitation = create_email_invitation_for_email(user.id, nil)
    # send activation email to user
    ActivateWaitlistUserWorker.perform_async(user.id.to_s, invitation.id.to_s)
  end

  # @param [String] handles
  def get_users_by_handles(handles)
    User.where(:handle.in => handles).map { |u| u[:name] = u.name; u }
  end

  def get_users_map_handles(handles)
    if handles.blank?
      return Hash.new
    end
    handles.compact!
    users = User.where(:handle.in => handles)
    user_map = Hash.new
    unless users.blank?
      users.each do |user|
        user_map[user.handle] = user
      end
    end
    user_map
  end

  def get_users_map_ids(ids)
    users = User.find(ids)
    user_map = Hash.new
    unless users.blank?
      users.each do |user|
        user_map[user.id] = user
      end
    end
    user_map
  end

  def get_active_users_map(ids)
    ids = ids.compact
    users = User.find(ids)
    user_map = Hash.new
    unless users.blank?
      users.each do |user|
        if user.active
          user_map[user.id] = user
        end
      end
    end
    user_map
  end

  def save_user(params)
    if session[:reg_email].blank?
      return nil
    end
    user = User.find(session[:reg_email])
    unless params[:primary_email].blank?
      user[:email] = params[:primary_email]
      user[:primary_email] = params[:primary_email]
    end
    user[:alumni] = !params[:alumni].blank?
    user[:degree] = params[:degree]
    user[:phone_number] = params[:phone_field]
    major = get_majors_for_ids(params[:major])
    user[:major] = major[:major]
    user[:major_id] = major[:_id]
    minor = get_majors_for_ids(params[:minor])
    unless minor.blank?
      user[:minor] = minor[:major]
      user[:minor_id] = minor[:_id]
    end
    user[:year] = params[:year]
    user[:create_dttm] = Time.zone.now
    user[:last_login_dttm] = Time.zone.now
    user[:password_hash] = encrypt_password(params[:password])
    unless params[:gpa].blank?
      user[:gpa] = params[:gpa].to_f
    end
    begin
      user.save
      update_session_with_user(user)
    rescue Exception => ex
    end
    user
  end

  def create_influencer(params)
    id = params[:primary_email]
    if id.blank?
      return
    end
    user = User.find(id)
    if user.blank?
      user = User.new
      user.id = id
    end
    user[:first_name] = params[:first_name]
    unless params[:primary_email].blank?
      user[:email] = params[:primary_email]
    end
    unless params[:headline].blank?
      user[:headline] = params[:headline]
    end

    unless params[:bio].blank?
      user[:bio] = params[:bio]
    end

    user[:school_id] = params[:school_id]
    user[:other_school_ids] = params[:other_school_ids]
    user[:last_name] = params[:last_name]
    unless is_handle_available(params[:handle])
      params[:handle] = get_next_handle_from_name(params[:first_name], params[:last_name])
    end
    user[:handle] = process_handle(params[:handle].downcase)
    user[:badge] = UserBadgeTypes::INFLUENCER
    user[:active] = params[:active]
    user[:create_dttm] = Time.zone.now
    user[:last_login_dttm] = Time.zone.now
    user[:password_hash] = encrypt_password(params[:password])
    unless params[:image_url].blank?
      user.image_url = params[:image_url]
      image_url = get_cloudinary_large_image_url(user.handle, params[:image_url])
      user.large_image_url = image_url.blank? ? params[:image_url] : image_url
      user.small_image_url = get_cloudinary_facial_image_url(user.handle, image_url.blank? ? params[:image_url] : image_url)
    end

    unless params[:company_id].blank?
      company = get_or_create_company_by_name(params[:company_id])
      unless company.blank?
        user[:company_id] = company.id
      end
    end

    unless params[:company_ids].blank?
      company_ids = get_or_create_company_ids(params[:company_ids])
      user[:company_ids] = company_ids
    end

    unless params[:majorTypes].blank?
      user[:major_types] = params[:majorTypes]
    end

    if user.save
      update_session_with_user(user)
    end
    # Creating User Settings
    settings = UserSettings.find_or_create_by(handle: user[:handle])
    settings.notification_email_subscriptions = {'job' => params.has_key?('job'), 'company' => params.has_key?('company'), 'message' => params.has_key?('message'),
                                                 'social' => params.has_key?('social'), 'tips' => params.has_key?('tips')}
    settings.save
    user
  end

  def create_user(params, email_invitation)
    if email_invitation.blank?
      id = params[:university_email]
    else
      id = email_invitation[:email]
    end
    if id.blank?
      return
    end
    user = User.find(id)
    if user.blank?
      user = User.new
      user.id = id
    end
    user[:first_name] = params[:first_name]
    unless params[:primary_email].blank?
      user[:email] = params[:primary_email]
    end
    unless params[:headline].blank?
      user[:headline] = params[:headline]
    end
    user[:image_url] = params[:image_url]
    user[:last_name] = params[:last_name]
    unless is_handle_available(params[:handle])
      params[:handle] = get_next_handle_from_name(params[:first_name], params[:last_name])
    end
    user[:handle] = process_handle(params[:handle].downcase)
    user[:alumni] = params.has_key? 'alumni'
    user[:degree] = params[:degree]
    user[:phone_number] = params[:phone_field]
    major = get_majors_for_ids(params[:major])
    if major.blank?
      # create the major
      major = create_major(params[:degree], params[:major])
    end
    unless major.blank?
      user[:major] = major[:major]
      user[:major_id] = major[:_id]
    end

    if params[:minor]
      minor = get_majors_for_ids(params[:minor])
      if minor.blank?
        # create the minor
        minor = create_major(params[:degree], params[:minor])
      end
      unless minor.blank?
        user[:minor] = minor[:major]
        user[:minor_id] = minor[:_id]
      end
    end
    user[:year] = params[:year]
    user[:active] = params[:active]
    user[:create_dttm] = Time.zone.now
    user[:last_login_dttm] = Time.zone.now
    user[:password_hash] = encrypt_password(params[:password])

    if params[:image_url].blank? or params[:image_url].include? DIRTY_PICTURE
      text = user.first_name[0] + user.last_name[0]
      user.image_url = get_place_holder_image_url(text, TINY_WIDTH, TINY_WIDTH)
      user.small_image_url = get_place_holder_image_url(text, SMALL_WIDTH, SMALL_WIDTH)
      user.large_image_url = get_place_holder_image_url(text, MEDIUM_WIDTH, MEDIUM_WIDTH)
    else
      user.image_url = params[:image_url]
      image_url = get_cloudinary_large_image_url(user.handle, params[:image_url])
      user.large_image_url = image_url.blank? ? params[:image_url] : image_url
      user.small_image_url = get_cloudinary_facial_image_url(user.handle, image_url.blank? ? params[:image_url] : image_url)
    end
    unless params[:gpa].blank?
      user[:gpa] = params[:gpa].to_f
    end
    save_user_after_checks(user)
    update_session_with_user(user)

    # Creating User Settings
    settings = UserSettings.find_or_create_by(handle: user[:handle])
    settings.notification_email_subscriptions = {'job' => params.has_key?('job'), 'company' => params.has_key?('company'), 'message' => params.has_key?('message'),
                                                 'social' => params.has_key?('social'), 'tips' => params.has_key?('tips')}
    settings.save
    begin
      user.save
    rescue Exception => ex
    end
    seed_collections_for_user(user)
    unless params[:referrer].blank?
      reward_for_friend_referral(params[:referrer], user.handle)
      # create a notification for referrer
      create_notification(params[:referrer], user.handle, user.handle, MeedNotificationType::FRIEND_JOINED)
    end
    IntercomConvertContactWorker.perform_async(user.id, params[:referrer])
    user
  end

  def get_waitlist_user(id)
    WaitlistUser.find(id)
  end

  def get_badge_for_user(user)

  end

  def put_in_wait_list(school_handle, email, params = {})
    wait_list = WaitListInvitation.find_by(handle: school_handle)
    if wait_list.blank?
      email_ids = Array.new
      email_ids << email
      wait_list = WaitListInvitation.new
      wait_list.id = school_handle
      wait_list.handle = school_handle
      wait_list.email_ids = email_ids
    else
      wait_list.push(:email_ids, email)
    end
    wait_list.save
    wait_list_user = WaitlistUser.find(email)
    unless wait_list_user.blank?
      user = WaitlistUser.new
      user[:first_name] = params[:first_name]
      unless params[:primary_email].blank?
        user[:email] = params[:primary_email]
      end
      unless params[:headline].blank?
        user[:headline] = params[:headline]
      end

      unless params[:summary].blank?
        user[:summary] = params[:summary]
      end

      user[:last_name] = params[:last_name]
      unless is_handle_available(params[:handle])
        params[:handle] = get_next_handle_from_name(params[:first_name], params[:last_name])
      end
      user[:handle] = process_handle(params[:handle].downcase)
      user[:alumni] = params.has_key? 'alumni'
      user[:degree] = params[:degree]
      user[:phone_number] = params[:phone_field]
      major = get_majors_for_ids(params[:major])
      if major.blank?
        # create the major
        major = create_major(params[:degree], params[:major])
      end
      unless major.blank?
        user[:major] = major[:major]
        user[:major_id] = major[:_id]
      end

      minor = get_majors_for_ids(params[:minor])
      if minor.blank?
        # create the minor
        minor = create_major(params[:degree], params[:minor])
      end
      unless minor.blank?
        user[:minor] = minor[:major]
        user[:minor_id] = minor[:_id]
      end
      user[:year] = params[:year]
      user[:active] = params[:active].blank? ? true : params[:active]
      user[:create_dttm] = Time.zone.now
      user[:last_login_dttm] = Time.zone.now
      user[:password_hash] = encrypt_password(params[:password])
      unless params[:gpa].blank?
        user[:gpa] = params[:gpa].to_f
      end
      begin
        user.save
      rescue Exception => ex
      end
    end
  end

  def get_users_from_school(school_handle)
    unless school_handle.blank?
      school_email_regex = Regexp.new('.*' + school_handle + "\\.edu")
      User.where(email: school_email_regex, active: true).order_by([:create_time, -1])
    end
  end

  def is_handle_available(handle)
    # should check among even in in active handles
    user = User.find_by(:handle => handle.downcase)
    # should check in companies too
    company = Company.find(handle)
    return true if (user.blank? && company.blank?)
    false
  end

  def get_next_handle_from_name(first_name, last_name)
    words = first_name.split(' ')
    last_name = last_name.blank? ? '' : last_name.gsub(/\s+/, '')
    (0..2).each do |i|
      prefix = ''
      words.each do |word|
        prefix = prefix+word[0..i]
        handle = prefix + last_name
        handle = handle.downcase
        if is_handle_available(handle)
          return handle
        else
          get_next_handle_from_name(first_name[0, first_name.length-1], last_name[0, last_name.length-1])
        end
      end
    end
    return nil
  end

  def is_registered_user(email)
    user = User.find(email)
    if user.blank? or !user[:active]
      return false
    end
    true
  end

  def can_receive_job_alert(job, user)
    if user.blank? or job.blank?
      return false
    end
    inbox_key = get_user_inbox_key(user[:handle])
    job[:schools].each do |school|
      job[:majors].each do |major|
        job_inbox_key = (school + '_' + major)
        if job_inbox_key.eql? inbox_key
          logger.info("eligible to receive alert - job_inbox_key: #{job_inbox_key} and inbox_key: #{inbox_key} for user - #{user[:handle]}")
          return true
        end
      end
    end
    false
  end

  def user_follow(company_id, handle)
    user_follows = UserFollow.find(handle)
    if user_follows.blank?
      user_follows = UserFollow.new(:user_handle => handle)
    end
    user_follows.add_to_set(:company_ids, company_id)
    user_follows.save
    if user_follows.company_ids.count > 3
      save_user_state(handle, UserStateTypes::FOLLOW_COMPANY_DATE, true)
    end
  end

  def user_unfollow(company_id, handle)
    UserFollow.where(_id: handle).pull(:company_ids, company_id)
  end

  def get_user_follows(handle)
    user_follows = UserFollow.find(handle)
    if user_follows.blank?
      user_follows = UserFollow.new(:user_handle => handle)
      user_follows.save
    end
    user_follows
  end

  def admin_all_users
    User.all
  end

  def get_user_degress()
    degrees = User.all().pluck(:degree).uniq
    degrees.delete("N/a")
    return degrees
  end

  def skills_by_major
    skills = {}
    skills['all'] = Set.new();
    User.where(:active => true).all().each do |user|
      major_id = user[:major_id];
      unless skills.has_key? major_id
        skills[major_id] = Set.new();
      end
      course_skills = UserCourse.where(:handle => user[:handle]).pluck(:skills).flatten;
      course_skills = course_skills.collect { |s| generate_skills(s) }.flatten.uniq
      experience_skills = UserWork.where(:handle => user[:handle]).pluck(:skills).flatten;
      experience_skills = experience_skills.collect { |s| generate_skills(s) }.flatten.uniq
      internship_skills = UserInternship.where(:handle => user[:handle]).pluck(:skills).flatten;
      internship_skills = internship_skills.collect { |s| generate_skills(s) }.flatten.uniq
      publication_skills = UserPublication.where(:handle => user[:handle]).pluck(:skills).flatten;
      publication_skills = publication_skills.collect { |s| generate_skills(s) }.flatten.uniq
      skills[major_id].merge(course_skills)
      skills[major_id].merge(experience_skills)
      skills[major_id].merge(internship_skills)
      skills[major_id].merge(publication_skills)
      skills['all'].merge(skills[major_id])
    end
    skills
  end

  def get_user_state(handle)
    user_state = UserState.find(handle)
    user_state = UserState.find(handle)
    if user_state.blank?
      user_state = UserState.new
      user_state.id = handle
      user_state.handle = handle
    end
    user_state.save
    user_state

  end

  def save_user_state(handle, user_state_type, intercom_update = true, action = 'new-hire')
    if handle.blank? or user_state_type.blank?
      return
    end
    user_state = UserState.find(handle)
    if user_state.blank?
      user_state = UserState.new
      user_state.id = handle
      user_state.handle = handle
    end
    case UserStateTypes.const_get(user_state_type.upcase)
      when UserStateTypes::APPLY_JOBS_DATE
        user_state.apply_jobs_date = Time.now
      when UserStateTypes::COMMENT_RECEIVE_DATE
        user_state.last_comment_receive_date = Time.now
      when UserStateTypes::UPVOTE_RECEIVE_DATE
        user_state.last_upvote_receive_date = Time.now
      when UserStateTypes::FOLLOWER_RECEIVE_DATE
        user_state.last_follower_receive_date = Time.now
      when UserStateTypes::MEED_BADGE
        user_state.meed_badge = action
      when UserStateTypes::LAST_SUBMISSION_DATE
        user_state.last_submission_date = Time.now
      when UserStateTypes::PORTFOLIO_SUBMISSION
        user_state.last_portfolio_submission_date = Time.now
      when UserStateTypes::FOLLOW_COLLECTION_DATE
        user_state.follow_collection_date = Time.now
      when UserStateTypes::CREATE_COLLECTION_DATE
        user_state.create_collection_date = Time.now
      when UserStateTypes::LAST_PROFILE_UPDATED
        user_state.last_profile_updated = Time.now
      when UserStateTypes::FOLLOW_COMPANY_DATE
        user_state.follow_company_date = Time.now
      when UserStateTypes::PROFILE_COMPLETE
        user_state.profile_complete = true
      when UserStateTypes::PROFILE_PICTURE_BLANK
        user_state.profile_picture_blank = action.eql? 'true'
      when UserStateTypes::FACEBOOK_IMPORT
        user_state.facebook_import = true
    end
    user_state.save

    if intercom_update
      IntercomUpdateUserStateWorker.perform_async(handle)
    end
  end

  def build_user_lead_models(leads)
    leads.each do |lead|
      lead[:name] = "#{lead.first_name} #{lead.last_name}"
      headline = "Class of #{lead.year} @#{get_school_handle_from_email(lead.id).upcase}"
      lead[:headline] = headline
      text = ""
      unless lead.first_name.blank?
        text = "#{lead.first_name[0]}"
      end
      unless lead.last_name.blank?
        text = "#{text} #{lead.last_name[0]}"
      end
      textsize = 100 - (10*(text.length - 1))
      lead[:lead] = true
      lead[:image_url] = "https://placeholdit.imgix.net/~text?txtsize=#{textsize}&bg=222222&txtclr=ffffff&txt=#{text}&w=#{TINY_WIDTH}&h=#{TINY_WIDTH}&txttrack=0"
      lead[:small_image_url] = "https://placeholdit.imgix.net/~text?txtsize=#{textsize}&bg=222222&txtclr=ffffff&txt=#{text}&w=#{SMALL_WIDTH}&h=#{SMALL_WIDTH}&txttrack=0"
      lead[:large_image_url] = "https://placeholdit.imgix.net/~text?txtsize=#{textsize}&bg=222222&txtclr=ffffff&txt=#{text}&w=#{MEDIUM_WIDTH}&h=#{MEDIUM_WIDTH}&txttrack=0"
    end
  end

  def build_intercom_user_lead_models(leads)
    leads.each do |lead|
      lead[:name] = "#{lead['name']} #{lead['custom_data']['Last Name']}"
      headline = "Class of #{lead["year"]} @#{get_school_handle_from_email(lead["email"]).upcase}"
      lead[:headline] = headline
      text = lead[:name].split(' ').take(2).map { |n| n[0] }.join()
      lead[:lead] = true
      lead[:image_url] = get_place_holder_image_url(text, TINY_WIDTH, TINY_WIDTH)
      lead[:small_image_url] = get_place_holder_image_url(text, SMALL_WIDTH, SMALL_WIDTH)
      lead[:large_image_url] = get_place_holder_image_url(text, MEDIUM_WIDTH, MEDIUM_WIDTH)
    end
  end

  def build_user_models(viewer=nil, users)
    if users.blank?
      return Array.new
    end
    users.compact!
    viewer_followee_ids = []
    unless viewer.blank?
      viewer_followee_ids = get_user_followee_ids(viewer.handle)
    end
    company_ids = []
    users.each do |user|
      unless user.company_id.blank?
        company_ids << user.company_id
      end

      unless user.company_ids.blank?
        company_ids.concat user.company_ids
      end
    end

    company_map = get_company_map(company_ids)
    users.each do |user|
      user[:name] = user.name
      unless user.company_id.blank?
        company = company_map[user[:company_id]]
        unless company.blank?
          user[:current_company] = company.name
        end
      end

      unless viewer.blank?
        user[:is_viewer_following] = viewer_followee_ids.include? user.handle
        if user.handle.eql? viewer.handle
          user[:is_viewer_following] = true
        end
      end

      unless user.company_ids.blank?
        company_names = []
        user.company_ids.each do |company_id|
          company = company_map[company_id]
          unless company.blank?
            company_names << company.name
          end
        end
        user[:company_names] = company_names
      end
    end

    users
  end

  def build_user_model(user)
    user[:name] = user.name
    user
  end
end
