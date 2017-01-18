class EmailVerifyWorker
  include Sidekiq::Worker
  include CrmManager
  sidekiq_options :retry => 5, :queue => :critical

  def perform(email)
    email_invitation = create_email_invitation_for_email(email, nil)
    if email_invitation.blank?
      return
    end
    Notifier.email_verification(email, email_invitation[:token]).deliver
  end

end