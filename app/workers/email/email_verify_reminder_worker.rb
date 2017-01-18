class EmailVerifyReminderWorker
  include Sidekiq::Worker
  include CrmManager
  sidekiq_options :retry => 5, :queue => :default

  def perform(email)
    email_invitation = get_email_invitation_for_email(email)
    if email_invitation.blank?
      return
    end
    Notifier.email_verification_reminder(email, email_invitation[:token]).deliver
  end
end