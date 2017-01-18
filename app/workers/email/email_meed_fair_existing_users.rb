class EmailMeedFairExistingUsers
  include UsersHelper
  include JobsManager
  include Sidekiq::Worker

  sidekiq_options retry: true, :queue => :default

  FAIR_START_DATE = "2015-04-15"
  FAIR_END_DATE = "2015-05-30"
  # sends emails to the users about the meed fair
  def perform(user_id)
    user = User.find(user_id)
    unless user[:handle].blank?
      profile = Profile.find(user[:handle])
    end

    # find relevant jobs - Jobs that are posted later than
    school = get_school_handle_from_email(user.email)
    major_id = user[:major_id]
    applied_jobs = UserJobAppStats.where(handle: user[:handle]).pluck(:job_id).uniq;
    jobs = Job.where(live: true).where(:create_dttm.gt => FAIR_START_DATE).where(:create_dttm.lt => FAIR_END_DATE).
        where(schools: school).where(majors: major_id).where(:company_id.ne => "resu.me").where(:_id.nin => applied_jobs);
    # if users is graduating greater >= 2016 we show only internships. if graduation year <= 2015 we show full time
    if user[:year].to_i >= 2016 && user[:year].to_i > 0
      jobs = jobs.where(:type.in => ["Internship", "intern"])
    end
    if user[:year].to_i <= 2015 && user[:year].to_i > 0
      jobs = jobs.where(:type.nin => ["full_time_entry_level", "Full Time (Experienced)", "full_time_experienced", "Full Time (Entry Level)"])
    end
    if jobs.count() == 0
      return
    end
    job_ids = jobs.map{|job| job[:_id]}
    if profile.blank?
      # sort ascending order of match pool count
      jobs = jobs.sort_by{|job| job[:match_pool_count]}
    else
      jobs = sort_jobs_by_profile(profile, user, job_ids)
    end
    # group companies by company id and take the first for each company
    job_groups = jobs.group_by{|job| job[:company_id]}
    jobs = job_groups.map{|group| group[1][0]}
    build_job_models(jobs)
    Notifier.email_meed_fair_existing_users(user, jobs).deliver
  end
end