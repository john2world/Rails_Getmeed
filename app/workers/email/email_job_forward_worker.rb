class EmailJobForwardWorker
  include Sidekiq::Worker
  include JobsManager
  sidekiq_options retry: true, :queue => :default

  def perform(user_id, to_email, job_hash)
    if user_id.blank? or to_email.blank? or job_hash.blank?
      return
    end
    user = User.find(user_id)
    if user.blank?
      return
    end
    job = get_job_by_hash(job_hash)
    if job.blank? or !job.live
      return
    end
    Notifier.email_job_forward(user, to_email, job).deliver
  end

end