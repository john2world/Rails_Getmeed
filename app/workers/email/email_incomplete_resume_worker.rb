class EmailIncompleteResumeWorker
  include Sidekiq::Worker
  include UsersManager
  include CrmManager
  include ProfilesHelper
  include ProfilesManager


  sidekiq_options retry: true, :queue => :default

  def perform(id)
    user = get_user_by_email id

    if user.blank?
      return
    end

    profile = get_user_profile_or_new(user.handle)
    if !profile.blank? and is_incomplete_profile(profile)
        logger.info('Sending incomplete resume email to: ' + user.id)
        Notifier.email_incomplete_resume(user).deliver
    end
  end
end