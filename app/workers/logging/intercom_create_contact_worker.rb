class IntercomCreateContactWorker
  include Sidekiq::Worker
  include IntercomManager
  sidekiq_options retry: true, :queue => :default

  def perform(user_id, referrer)
    user = User.find(user_id)
    if user.blank?
      return
    end
    iu_contact = create_intercom_contact(user, referrer)
  end
end