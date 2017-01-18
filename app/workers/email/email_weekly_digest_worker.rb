class EmailWeeklyDigestWorker
  include Sidekiq::Worker
  include FeedItemsManager
  include ProfilesManager
  include UsersManager
  include JobsManager

  sidekiq_options retry: true, :queue => :default

  def perform(user_id)
    if user_id.blank?
      return
    end
    user = User.find(user_id)
    if user.blank? || user.active == false
      return
    end

    feed_items = get_feed_items_for_user(user, true)
    jobs = get_jobs_for_user(user, false, true)

    current_year = DateTime.now.year
    graduation_year = user.year.to_i
    if graduation_year < current_year
      return
    end
    unless jobs.blank?
      if graduation_year > (current_year + 1)
        # filter jobs to internships
        jobs = jobs.select{|job| job[:type] == 'Internship' || job[:type] == 'intern'}
      else
        # filter jobs to non-internships = fulltime
        jobs = jobs.select{|job| !(job[:type] == 'Internship' || job[:type] == 'intern')}
      end
    end
    logger.info("Sending weekly digest email to #{user.id}")
    Notifier.email_meed_digest(user, jobs, feed_items).deliver
  end

end