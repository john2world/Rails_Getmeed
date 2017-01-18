class EmailMeedPointsThanksWorker
  include Sidekiq::Worker
  include UsersManager
  sidekiq_options retry: true, :queue => :default


  def perform(handle, type)

    user = get_user_by_handle(handle)
    if user.blank?
      logger.info("user not found. Not sending email for #{handle}")
      return
    end
    user[:rank] = get_leaderboard_rank(user[:meed_points])
    # Notifier.email_meed_points_thanks(user, type).deliver
  end
end