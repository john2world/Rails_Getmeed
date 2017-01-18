module AdminsManager
  include ArticlesManager
  include UsersManager

  def admin_recent_n_blogs(num)
    blogs = FeedItems.order_by([:_id, -1]).limit(num)
    blogs.each do |blog|
      blog.description = Sanitize.clean(blog.description)
    end
    blogs
  end


  def get_active_users_count
    return User.where(active: true).count()
  end

  def get_dashboard_keymetrics
    metrics = {}
    #intercom_segment_counts = IntercomClient.counts.for_type(type: 'user', count: 'segment').user["segment"].reduce({}, :merge)
    # getting total users metric
    time_pst = Time.now().in_time_zone("Pacific Time (US & Canada)")
    day_start_utc = time_pst.to_date.to_time - Time.zone_offset('PST')
    users = User.where(active: true);
    metrics[:total_active_users] = users.count()

    metrics[:school_counts] = users.group_by{|user| get_school_handle_from_email(user.id)}.map{|k,v| {label: k, value: v.count()}}
    metrics[:year_counts] = users.group_by{|user| user.year}.map{|k,v| {label: k, value: v.count()}}
    #metrics[:total_active_users] = intercom_segment_counts["Consumers"]
    #if metrics[:total_active_users].blank?
    #  metrics[:total_active_users] = 0
    #end

    # getting WAU
    metrics[:week_active_users] = users.where(:create_dttm.lt => 7.days.ago, :last_login_dttm.gte => 7.days.ago).count()
    #metrics[:week_active_users] = intercom_segment_counts["WAU"]
    #if metrics[:week_active_users].blank?
    #  metrics[:week_active_users] = 0
    #end
    # getting WNU
    users_last_month = users.where(:create_dttm.gte => 30.days.ago, active: true);
    handles = users_last_month.pluck(:handle)
    profiles = Profile.find(handles)
    metrics[:profile_completness] = '%.2f' % [profiles.select{|profile| !is_incomplete_profile(profile)}.count() * 100.0/profiles.count()]
    daily_growth_histogram = users_last_month.asc(:create_dttm).group_by{|u| u.create_dttm.strftime('%Y-%m-%d')}.map{|k,v| {:period => k, :DNU => v.count()}}
    metrics[:daily_new_users_trend] = daily_growth_histogram
    weekly_growth_histogram = users.where(:create_dttm.gte => 10.weeks.ago, active: true).asc(:create_dttm);
    weekly_growth_histogram = weekly_growth_histogram.group_by{|u| u.create_dttm.strftime('%W')}.map{|k,v| {:period => Date.commercial(Time.now.year, k.to_i).to_s, :WNU => v.count()}};
    metrics[:week_new_users_trend] = weekly_growth_histogram
    # get counts by day
    metrics[:week_new_users] = users.where(:create_dttm.gte => 7.days.ago).count()

    # waitlist users
    waitlist_users = User.where(:waitlist_no.ne => nil)
    metrics[:total_waitlist_users] = waitlist_users.where(active: false).count()
    metrics[:activated_waitlist_users] = waitlist_users.where(active: true).count()
    signup_user_handles = waitlist_users.pluck(:handle)
    metrics[:waitist_friend_signups] = MeedPointsTransaction.where(type: MEED_POINTS_REWARD_TYPE::FRIEND_REFERRER, :handle.in => signup_user_handles).count()
    metrics[:waitlist_school_counts] = waitlist_users.group_by{|user| get_school_handle_from_email(user.id)}.map{|k,v| {label: k, value: v.count()}}
    start_week = day_start_utc.at_beginning_of_week - 1.day
    start_week_pst = time_pst.at_beginning_of_week - 1.day
    start_week_utc = start_week_pst - Time.zone_offset('PST')
    metrics[:week_new_waitlist_user] = waitlist_users.where(:create_dttm.gt => start_week_utc, :create_dttm.lt => day_start_utc).count()
    metrics[:day_new_waitlist_user] = waitlist_users.where(:create_dttm.gt => (day_start_utc - 1.day), :create_dttm.lt => day_start_utc).count()
    metrics[:current_waitlist_user] = waitlist_users.where(:create_dttm.gt => day_start_utc).count()

    metrics[:week_waitlist_users_trend] = waitlist_users.where(:create_dttm.gt => 15.days.ago).
        group_by{|user| user.create_dttm.in_time_zone("Pacific Time (US & Canada)").to_date}.
        map{|k,v| {:period => k.to_s, :WLNU => v.count()}}.sort_by{|t| t[:period]}
    #metrics[:week_new_users] = intercom_segment_counts["WNU"]
    #if metrics[:week_new_users].blank?
    #  metrics[:week_new_users] = 0
    #end
    # get the WAU's for last 10 weeks
    wau_trend = []
    end_week = Date.today.at_beginning_of_week
    start_week = end_week - 1.week
    (1..10).each do |i|
      wau_trend.append({:period => start_week.to_s, :WAU => users.where(:create_dttm.lt => start_week, :last_login_dttm.gte => start_week, :last_login_dttm.lte => end_week).count()})
      end_week = start_week
      start_week = end_week - 1.week
    end

    metrics[:week_active_users_trend] = wau_trend.reverse

    # Job metrics
    metrics[:active_jobs] = Job.where(live: true).count()
    metrics[:mini_intern_jobs] = Job.where(live: true, type: /Mini Internship/).count()
    metrics[:companies] = EnterpriseUser.where(:password_hash.ne => nil).pluck(:company_id).uniq.count()
    return metrics
  end

  def migrate_duplicate_handles
    # getting duplicates handles first
    handles = User.all().pluck(:handle).compact;
    dup_handles = handles.group_by{|h| h}.select{|k,v| v.count() > 1}.keys();
    # for each handle get users by create_dttm and except for first one, reassign handle
    dup_handles.each do |handle|
      users = User.where(handle: handle).asc(:create_dttm).to_a
      # remove the oldest element
      users.shift
      # for each user, get new handle
      users.each do |user|
        reassign_handle(user)
      end
    end
  end

  def reassign_handle(user)
    handle = get_handle_from_email(user.id)
    unless is_handle_available(handle)
      handle = get_next_handle_from_name(user.first_name, user.last_name)
    end
    unless handle.blank?
      user.handle = handle
      user.save
    end
  end
end
