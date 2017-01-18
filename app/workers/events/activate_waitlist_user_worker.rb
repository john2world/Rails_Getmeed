class ActivateWaitlistUserWorker
  include Sidekiq::Worker
  include UsersManager
  include CrmManager
  include IntercomManager
  sidekiq_options retry: true, :queue => :default

  def perform(user_id, invitation_id)
    user = get_user_by_email(user_id)
    if user.blank?
      return
    end
    invitation = get_email_invitation_by_id(invitation_id)
    if invitation.blank?
      return
    end
    # activate user
    # Moving the activation to Intercom. Since the user is already verified, we directly activate user
    activate_user_live(user.handle)
    # Add event that user is activated
    IntercomLoggerWorker.new.perform('waitlist-activated', user.id, {})
    # Update the user so that active true is reflected
    iu_user = get_intercom_user(user);
    update_intercom_user(user, iu_user)
  end
end