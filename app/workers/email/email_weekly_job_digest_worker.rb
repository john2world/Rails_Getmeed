class EmailWeeklyJobDigestWorker
  include Sidekiq::Worker
  include JobsManager

  sidekiq_options retry: true, :queue => :default

  def perform(user_id)
    if user_id.blank?
      return
    end
    user = User.find(user_id)
    if user.blank?
      return
    end
    # getting jobs without the applied jobs.
    jobs = get_jobs_for_user(user, false, true)
    current_year = DateTime.now.year
    graduation_year = user.year.to_i
    if graduation_year < current_year
      return
    end
    if graduation_year > (current_year + 1)
      # filter jobs to internships
      jobs = jobs.select{|job| job[:type] == 'Internship' || job[:type] == 'intern'}
    else
      # filter jobs to non-internships = fulltime
      jobs = jobs.select{|job| !(job[:type] == 'Internship' || job[:type] == 'intern')}
    end
    # there should be at least 5 jobs
    if jobs.count() < 5
      return
    end
    jobs = jobs.take(5)
    Notifier.email_weekly_digest_jobs(user, jobs).deliver
  end
end
