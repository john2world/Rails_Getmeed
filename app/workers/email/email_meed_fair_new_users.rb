class EmailMeedFairNewUsers
  include UsersHelper
  include JobsManager
  include Sidekiq::Worker

  sidekiq_options retry: true, :queue => :default

  # sends emails to the users about the meed fair
  def perform(user_id)
    user = User.find(user_id)
    Notifier.email_meed_fair_new_users(user).deliver
  end
end