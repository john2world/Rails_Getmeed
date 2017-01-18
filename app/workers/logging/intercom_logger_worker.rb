class IntercomLoggerWorker
  include Sidekiq::Worker
  include IntercomManager
  sidekiq_options retry: true, :queue => :default

  def perform(event_name, user_id, hash)
    user = User.find(user_id)
    if user.blank?
      return
    end
    begin
      iu_user = get_intercom_user(user);
    rescue
      iu_user = nil
    end

    if iu_user.blank?
      iu_user = create_intercom_user(user)
    end
    if iu_user.blank?
      return
    end
    log_intercom_event(event_name, iu_user, hash)
  end
end