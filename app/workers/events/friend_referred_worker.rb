class FriendReferredWorker
  include Sidekiq::Worker
  include UsersManager
  sidekiq_options retry: true, :queue => :default

  def perform(referred_friend_handle, joined_friend_handle)
    if referred_friend_handle.blank? || joined_friend_handle.blank?
      return
    end
    referred_friend = get_user_by_handle(referred_friend_handle)
    joined_friend = get_user_by_handle(joined_friend_handle)
    if referred_friend.blank? || joined_friend.blank?
      return
    end
    if !referred_friend.waitlist_no.blank? && !referred_friend.active
      # he is a waitlist user that is not activated.
      friend_count = get_friend_referral_count(referred_friend_handle)
      if friend_count < 3
        # we must send friend joined email
        Notifier.email_waitlist_friend_joined(referred_friend, joined_friend).deliver
      elsif friend_count >= 3
        # we must send the activation email and activate the user account
        # send activation to the referrer friend
        activate_wait_list_user(referred_friend)
        # send email to all the friends referred by the referrer_friend that the referred_friend is activated
        get_friends_referred(referred_friend_handle).each do |handle|
          user = get_user_by_handle(handle)
          unless user.blank?
            Notifier.email_waitlist_friend_activated(user, referred_friend).deliver
          end
        end
      end
    end
  end
end