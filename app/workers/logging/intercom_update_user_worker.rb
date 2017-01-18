class IntercomUpdateUserWorker
  include Sidekiq::Worker
  include UsersHelper
  include IntercomManager
  sidekiq_options retry: true, :queue => :default

  def perform(user_id, referrer = nil)
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
      create_intercom_user(user, referrer)
    else
      update_intercom_user(user, iu_user)
    end
  end
end