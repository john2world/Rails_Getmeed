class EmailCompanyViewWorker
  include Sidekiq::Worker
  include JobsManager
  include UsersManager
  sidekiq_options retry: true, :queue => :default

  def perform(company_id, handle)
    if handle.blank?
      return
    end
    user = get_user_by_handle(handle)
    email = user.id
    unless user[:primary_email].blank?
      email = user.primary_email
    end
    # send notification only if user setting is Every. else it will go as part of the digest
    setting = UserSettings.find_or_create_by(handle: handle);
    if setting.email_frequency != :EVERY
      return;
    end
    company = get_company_by_id(company_id)
    logger.info('Sending company viewed email to: ' + email)
    Notifier.email_company_view(email, company).deliver
  end
end