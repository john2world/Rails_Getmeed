class EmailThanksGivingWorker
  include Sidekiq::Worker
  include UsersManager
  include ProfilesHelper
  include CrmManager

  sidekiq_options retry: true, :queue => :default

  def perform(email)
    user = get_user_by_email email
    Notifier.email_thanksgiving(user).deliver
    track_email_send('thanksgiving_tshirt_claim')
  end
end