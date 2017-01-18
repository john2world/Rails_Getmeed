class IntercomUpdateUserStateWorker
  include Sidekiq::Worker
  include UsersHelper
  include IntercomManager
  sidekiq_options retry: true, :queue => :default

  def perform(user_id)
    user_state = UserState.where(:handle => user_id).first
    user = User.where(:handle => user_id).first
    if user_state.blank? or user.blank?
      return false
    end
    update_intercom_user_state(user, user_state)
  end
end