class EmailJobNewApplicantWorker
  include Sidekiq::Worker
  include UsersManager
  include JobsManager
  sidekiq_options retry: true, :queue => :default


  def perform(job_id, handle)
    if job_id.blank?
      return
    end
    if handle.blank?
      return
    end

    user = get_user_by_handle(handle)
    job_app = JobApplicant.find("#{handle}_#{job_id}")
    job = get_job_by_id(job_id)
    if user.blank? or job_app.blank?
      return
    end

    Notifier.email_job_notification(job, job_app, user).deliver
  end

end