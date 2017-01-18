class ProfileViewWorker
  include Sidekiq::Worker
  include EnterpriseUsersManager
  include UsersManager
  include JobsManager
  include CrmManager
  include NotificationsManager

  sidekiq_options retry: true

  def perform(user_handle, job_id, short_list)
    if user_handle.blank?
      return
    end
    user = get_user_by_handle(user_handle)
    job = get_job_by_id(job_id)
    if user.blank? or job.blank?
      return
    end
    change_job_app_status('VIEWED', job_id, user_handle)
    if short_list
      Notifier.email_job_application_view(user, job, short_list).deliver
      create_notification(user.handle, job.company_id, job.id, MeedNotificationType::JOB_SHORTLIST)
    else
      application = JobApplicant.find(user[:handle]+'_'+ job.id.to_s)
      unless application.opened
        Notifier.email_job_application_view(user, job, short_list).deliver
        application.opened = true
        application.save
        create_notification(user.handle, job.company_id, job.id, MeedNotificationType::JOB_APPLICATION_OPEN)
      end
    end
  end

end