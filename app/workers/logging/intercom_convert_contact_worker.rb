class IntercomConvertContactWorker
  include Sidekiq::Worker
  include UsersHelper
  include IntercomManager
  sidekiq_options retry: true, :queue => :critical

  def perform(user_id, referrer)
    user = User.find(user_id)
    if user.blank?
      return
    end
    iu_user = convert_intercom_contact_to_user(user, referrer)
    if user.badge.eql? 'influencer'
      seed_collections_for_influencer(user)
    else
      seed_collections_for_user(user)
    end
    IntercomUpdateUserWorker.perform_async(user_id, referrer)
    # this is already being set in contact as attribute and ported over to user when it is converted. we are also adding an event
    IntercomLoggerWorker.perform_async("contact-converted", user_id, {referrer: referrer})
  end
end