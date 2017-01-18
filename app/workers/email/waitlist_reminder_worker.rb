class WaitlistReminderWorker
  include Sidekiq::Worker
  include CrmManager
  include UsersManager
  include MeedPointsTransactionManager
  sidekiq_options :retry => 5, :queue => :default

  def perform(handle, reminder_count = 0)
    user = get_user_by_handle(handle)
    if user.blank?
      return
    end
    # if the user is already activated return
    if user.active
      return
    end
    if reminder_count >= 1
      # activate
      activate_wait_list_user(user)
      return
    end
    # if the user already invited three friends but did not activate the account this is not the right email
    friend_count = get_friend_referral_count(user.handle)
    if friend_count > MeedPointsTransactionManager::WaitlistFriendReferrerCount
      return
    end
    # we don't want to send reminder more than 3 times
    if reminder_count >= 3
      return
    end
    # send email and schedule the next message
    Notifier.email_waitlist_reminder(user, reminder_count).deliver
    # schedule next email in 1 week
    WaitlistReminderWorker.perform_at(3.days.from_now, handle, (reminder_count + 1))
  end
end