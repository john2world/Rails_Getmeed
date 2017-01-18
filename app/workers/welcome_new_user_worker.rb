class WelcomeNewUserWorker
  include Sidekiq::Worker
  include CrmManager
  include UsersManager
  sidekiq_options :retry => 5, :queue => :critical

  def perform(user_id)
    user = get_user_by_handle(user_id)
    if user.blank?
      return
    end
    Notifier.email_welcome(user).deliver
  end
end