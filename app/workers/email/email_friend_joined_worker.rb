class EmailFriendJoinedWorker
  include Sidekiq::Worker
  include UsersManager
  include ConnectionsManager
  include NotificationsManager
  include NotificationsHelper
  sidekiq_options retry: true, :queue => :default


  def perform(handle, friend_handle)
    if handle.blank? or friend_handle.blank?
      return
    end
    user = get_user_by_handle(handle)
    friend_user = get_user_by_handle(handle)
    if user.blank? or friend_user.blank?
      return
    end

    create_meed_friend_connection(handle, friend_handle)
    user[:rank] = get_leaderboard_rank(user[:meed_points])

    Notifier.email_friend_joined(user, friend_user).deliver
  end
end
