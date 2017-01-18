class EmailJobConfirmationWorker
  include Sidekiq::Worker
  include UsersManager
  include JobsManager
  sidekiq_options retry: true, :queue => :default

  def perform(handle, job_id)
    user = get_user_by_handle(handle)
    job = get_job_by_id(job_id)
    Notifier.email_job_confirmation(job, user).deliver
  end
end