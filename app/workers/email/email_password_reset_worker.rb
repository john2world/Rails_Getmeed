class EmailPasswordResetWorker
  include Sidekiq::Worker
  include CrmManager
  sidekiq_options retry: true, :queue => :critical

  def perform(email)
    @email_invitation = create_email_invitation_for_email(email, nil)
    Notifier.email_password_reset(email, @email_invitation[:_id]).deliver
  end

end