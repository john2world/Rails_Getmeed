class LeaderboardTopTenPositionWorker
  include Sidekiq::Worker
  include UsersManager

  sidekiq_options retry: true, :queue => :default

  def perform(user_id, rank)
    if user_id.blank?
      return
    end
    user = User.where(:handle => user_id).first
    if user.blank?
      return
    end
    user[:rank] = rank
    Notifier.email_leaderboard_top_ten_position(user).deliver
  end
end
