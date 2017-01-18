class EmailInvitationWorker
  include Sidekiq::Worker
  include UsersManager
  include UsersHelper
  include FeedItemsManager
  include ProfilesManager
  include CrmManager
  include CrmHelper

  sidekiq_options retry: true, :queue => :critical

  #current active variations email_invitation_5, email_invitation_0
  #email_invitaiton_0 = job

  def perform(email, invitor_id, variation_id, with_media)
  end

end