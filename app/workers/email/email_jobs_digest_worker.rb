class EmailJobsDigestWorker
  include Sidekiq::Worker
  include JobsManager
  sidekiq_options retry: true, :queue => :default

  def perform(job_ids, email)
    logger.info { job_ids.to_s + ' email: ' + email }
    if email.blank?
      return
    end
    if job_ids.blank?
      return
    end
    jobs = get_jobs_by_ids(job_ids)
    Notifier.email_job_alerts(email, jobs).deliver
  end

end